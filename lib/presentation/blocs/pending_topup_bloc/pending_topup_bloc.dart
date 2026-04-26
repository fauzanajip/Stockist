import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/pending_topup_entity.dart';
import '../../../domain/entities/stock_mutation_entity.dart';
import '../../../domain/usecases/pending_topup_usecases.dart';
import '../../../domain/usecases/stock_mutation_usecases.dart';
import '../../../domain/repositories/event_spg_repository.dart';
import 'pending_topup_event.dart';
import 'pending_topup_state.dart';

class PendingTopupBloc extends Bloc<PendingTopupEvent, PendingTopupState> {
  final GetPendingTopupsByEvent getPendingTopupsByEvent;
  final GetPendingTopupsByEventAndSpb getPendingTopupsByEventAndSpb;
  final CreatePendingTopupUsecase createPendingTopup;
  final UpdatePendingTopupUsecase updatePendingTopup;
  final DeletePendingTopupUsecase deletePendingTopup;
  final GetPendingTopupById getPendingTopupById;
  final CreateStockMutation createStockMutation;
  final DeleteStockMutationRecord deleteStockMutation;
  final EventSpgRepository eventSpgRepository;

  PendingTopupBloc({
    required this.getPendingTopupsByEvent,
    required this.getPendingTopupsByEventAndSpb,
    required this.createPendingTopup,
    required this.updatePendingTopup,
    required this.deletePendingTopup,
    required this.getPendingTopupById,
    required this.createStockMutation,
    required this.deleteStockMutation,
    required this.eventSpgRepository,
  }) : super(const PendingTopupState()) {
    on<LoadPendingTopupsEvent>(_onLoadPendingTopups);
    on<AddPendingTopupEvent>(_onAddPendingTopup);
    on<TogglePendingTopupCheckEvent>(_onTogglePendingTopupCheck);
    on<UpdatePendingTopupEvent>(_onUpdatePendingTopup);
    on<DeletePendingTopupEvent>(_onDeletePendingTopup);
    on<SelectPendingTopupEvent>(_onSelectPendingTopup);
    on<ClearSelectionEvent>(_onClearSelection);
  }

  Future<void> _onLoadPendingTopups(
    LoadPendingTopupsEvent event,
    Emitter<PendingTopupState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final topups = event.spbId != null
          ? await getPendingTopupsByEventAndSpb(event.eventId, event.spbId)
          : await getPendingTopupsByEvent(event.eventId);
      emit(state.copyWith(isLoading: false, pendingTopups: topups));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddPendingTopup(
    AddPendingTopupEvent event,
    Emitter<PendingTopupState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      
      final entity = PendingTopupEntity(
        id: '',
        eventId: event.eventId,
        spbId: event.spbId,
        spgId: event.spgId,
        productId: event.productId,
        qty: event.qty,
        type: PendingTopupType.topup,
        isChecked: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await createPendingTopup(entity);
      
      final topups = await getPendingTopupsByEvent(event.eventId);
      emit(state.copyWith(isLoading: false, pendingTopups: topups));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onTogglePendingTopupCheck(
    TogglePendingTopupCheckEvent event,
    Emitter<PendingTopupState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      
      final topup = await getPendingTopupById(event.id);
      if (topup == null) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Topup not found'));
        return;
      }
      
      if (topup.type == PendingTopupType.initial) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Cannot toggle INITIAL type'));
        return;
      }
      
      if (event.isChecked) {
        final mutation = await createStockMutation(
          CreateStockMutationParams(
            eventId: topup.eventId,
            spgId: topup.spgId,
            productId: topup.productId,
            qty: topup.qty,
            type: MutationType.topup,
          ),
        );
        
        final updated = topup.copyWith(
          isChecked: true,
          stockMutationId: mutation.id,
          updatedAt: DateTime.now(),
        );
        await updatePendingTopup(updated);
      } else {
        if (topup.stockMutationId != null) {
          await deleteStockMutation(topup.stockMutationId!);
        }
        
        final updated = topup.copyWith(
          isChecked: false,
          stockMutationId: null,
          updatedAt: DateTime.now(),
        );
        await updatePendingTopup(updated);
      }
      
      final topups = await getPendingTopupsByEvent(topup.eventId);
      emit(state.copyWith(isLoading: false, pendingTopups: topups));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdatePendingTopup(
    UpdatePendingTopupEvent event,
    Emitter<PendingTopupState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      
      final topup = await getPendingTopupById(event.id);
      if (topup == null) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Topup not found'));
        return;
      }
      
      final updated = topup.copyWith(
        spbId: event.spbId,
        spgId: event.spgId,
        productId: event.productId,
        qty: event.qty,
        updatedAt: DateTime.now(),
      );
      
      await updatePendingTopup(updated);
      
      final topups = await getPendingTopupsByEvent(topup.eventId);
      emit(state.copyWith(isLoading: false, pendingTopups: topups, selectedTopup: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeletePendingTopup(
    DeletePendingTopupEvent event,
    Emitter<PendingTopupState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      
      final topup = await getPendingTopupById(event.id);
      if (topup == null) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Topup not found'));
        return;
      }
      
      if (topup.isChecked && topup.stockMutationId != null) {
        await deleteStockMutation(topup.stockMutationId!);
      }
      
      await deletePendingTopup(event.id);
      
      final topups = await getPendingTopupsByEvent(topup.eventId);
      emit(state.copyWith(isLoading: false, pendingTopups: topups, selectedTopup: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  void _onSelectPendingTopup(
    SelectPendingTopupEvent event,
    Emitter<PendingTopupState> emit,
  ) {
    emit(state.copyWith(selectedTopup: event.topup));
  }

  void _onClearSelection(
    ClearSelectionEvent event,
    Emitter<PendingTopupState> emit,
  ) {
    emit(state.copyWith(selectedTopup: null));
  }
}