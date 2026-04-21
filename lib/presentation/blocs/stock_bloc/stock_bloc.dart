import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/stock_mutation_entity.dart';
import '../../../domain/usecases/stock_mutation_usecases.dart';
import 'stock_event.dart';
import 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final CreateStockMutation createStockMutation;
  final GetTotalGiven getTotalGiven;
  final GetTotalReturn getTotalReturn;
  final GetStockMutationsByEventSpg getStockMutationsByEventSpg;
  final GetStockMutationsByEvent getStockMutationsByEvent;

  StockBloc({
    required this.createStockMutation,
    required this.getTotalGiven,
    required this.getTotalReturn,
    required this.getStockMutationsByEventSpg,
    required this.getStockMutationsByEvent,
  }) : super(const StockState()) {
    on<CreateInitialDistribution>(_onCreateInitialDistribution);
    on<CreateTopup>(_onCreateTopup);
    on<CreateReturn>(_onCreateReturn);
    on<LoadStockByEventSpg>(_onLoadStockByEventSpg);
    on<LoadStockByEvent>(_onLoadStockByEvent);
  }

  Future<void> _onLoadStockByEvent(
    LoadStockByEvent event,
    Emitter<StockState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final mutations = await getStockMutationsByEvent(event.eventId);
      emit(state.copyWith(isLoading: false, mutations: mutations));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }


  Future<void> _onCreateInitialDistribution(
    CreateInitialDistribution event,
    Emitter<StockState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await createStockMutation(
        CreateStockMutationParams(
          eventId: event.eventId,
          spgId: event.spgId,
          productId: event.productId,
          qty: event.qty,
          type: MutationType.initial,
        ),
      );
      add(LoadStockByEventSpg(eventId: event.eventId, spgId: event.spgId));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateTopup(
    CreateTopup event,
    Emitter<StockState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await createStockMutation(
        CreateStockMutationParams(
          eventId: event.eventId,
          spgId: event.spgId,
          productId: event.productId,
          qty: event.qty,
          type: MutationType.topup,
          note: event.note,
        ),
      );
      add(LoadStockByEventSpg(eventId: event.eventId, spgId: event.spgId));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateReturn(
    CreateReturn event,
    Emitter<StockState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await createStockMutation(
        CreateStockMutationParams(
          eventId: event.eventId,
          spgId: event.spgId,
          productId: event.productId,
          qty: event.qty,
          type: MutationType.returnMutation,
          note: event.note,
        ),
      );
      add(LoadStockByEventSpg(eventId: event.eventId, spgId: event.spgId));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadStockByEventSpg(
    LoadStockByEventSpg event,
    Emitter<StockState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final mutations = await getStockMutationsByEventSpg(
        event.eventId,
        event.spgId,
      );

      // Basic counters (can be refined with StockCalculator if needed)
      final initialQty = mutations
          .where((m) => m.type == MutationType.initial)
          .fold(0, (sum, m) => sum + m.qty);
      final topupQty = mutations
          .where((m) => m.type == MutationType.topup)
          .fold(0, (sum, m) => sum + m.qty);
      final returnQty = mutations
          .where((m) => m.type == MutationType.returnMutation)
          .fold(0, (sum, m) => sum + m.qty);

      emit(
        state.copyWith(
          isLoading: false,
          mutations: mutations,
          totalGiven: initialQty + topupQty,
          totalReturn: returnQty,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
