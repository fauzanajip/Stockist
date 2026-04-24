import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/spg_product_target_entity.dart';
import '../../../domain/usecases/spg_product_target_usecases.dart';
import 'spg_target_event.dart';
import 'spg_target_state.dart';

class SpgTargetBloc extends Bloc<SpgTargetEvent, SpgTargetState> {
  final GetTargetsByEvent getTargetsByEvent;
  final GetTargetsByEventSpg getTargetsByEventSpg;
  final CreateSpgProductTarget createSpgProductTarget;
  final UpdateSpgProductTarget updateSpgProductTarget;
  final DeleteSpgProductTarget deleteSpgProductTarget;
  final BulkCreateOrUpdateTargets bulkCreateOrUpdateTargets;

  SpgTargetBloc({
    required this.getTargetsByEvent,
    required this.getTargetsByEventSpg,
    required this.createSpgProductTarget,
    required this.updateSpgProductTarget,
    required this.deleteSpgProductTarget,
    required this.bulkCreateOrUpdateTargets,
  }) : super(SpgTargetInitial()) {
    on<LoadTargetsByEvent>(_onLoadTargetsByEvent);
    on<LoadTargetsByEventSpg>(_onLoadTargetsByEventSpg);
    on<CreateTarget>(_onCreateTarget);
    on<UpdateTarget>(_onUpdateTarget);
    on<DeleteTarget>(_onDeleteTarget);
    on<BulkCreateOrUpdateTargetsEvent>(_onBulkCreateOrUpdateTargets);
  }

  Future<void> _onLoadTargetsByEvent(
    LoadTargetsByEvent event,
    Emitter<SpgTargetState> emit,
  ) async {
    try {
      emit(SpgTargetLoading());
      final targets = await getTargetsByEvent(event.eventId);
      emit(SpgTargetsLoaded(targets: targets));
    } catch (e) {
      emit(SpgTargetError(message: e.toString()));
    }
  }

  Future<void> _onLoadTargetsByEventSpg(
    LoadTargetsByEventSpg event,
    Emitter<SpgTargetState> emit,
  ) async {
    try {
      emit(SpgTargetLoading());
      final targets = await getTargetsByEventSpg(event.eventId, event.spgId);
      emit(SpgTargetsLoaded(targets: targets));
    } catch (e) {
      emit(SpgTargetError(message: e.toString()));
    }
  }

  Future<void> _onCreateTarget(
    CreateTarget event,
    Emitter<SpgTargetState> emit,
  ) async {
    try {
      emit(SpgTargetLoading());
      final target = await createSpgProductTarget(event.target);
      emit(SpgTargetCreated(target: target));
      add(LoadTargetsByEvent(eventId: target.eventId));
    } catch (e) {
      emit(SpgTargetError(message: e.toString()));
    }
  }

  Future<void> _onUpdateTarget(
    UpdateTarget event,
    Emitter<SpgTargetState> emit,
  ) async {
    try {
      emit(SpgTargetLoading());
      final target = await updateSpgProductTarget(event.target);
      emit(SpgTargetUpdated(target: target));
      add(LoadTargetsByEvent(eventId: target.eventId));
    } catch (e) {
      emit(SpgTargetError(message: e.toString()));
    }
  }

  Future<void> _onDeleteTarget(
    DeleteTarget event,
    Emitter<SpgTargetState> emit,
  ) async {
    try {
      emit(SpgTargetLoading());
      await deleteSpgProductTarget(event.id);
      emit(SpgTargetDeleted());
    } catch (e) {
      emit(SpgTargetError(message: e.toString()));
    }
  }

  Future<void> _onBulkCreateOrUpdateTargets(
    BulkCreateOrUpdateTargetsEvent event,
    Emitter<SpgTargetState> emit,
  ) async {
    try {
      emit(SpgTargetLoading());
      await bulkCreateOrUpdateTargets(event.targets);
      emit(SpgTargetsBulkSaved());
      if (event.targets.isNotEmpty) {
        add(LoadTargetsByEvent(eventId: event.targets.first.eventId));
      }
    } catch (e) {
      emit(SpgTargetError(message: e.toString()));
    }
  }
}