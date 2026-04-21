import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/spg_usecases.dart' as spg_usecase;
import '../../../domain/usecases/spb_usecases.dart' as spb_usecase;
import '../../../domain/usecases/event_spg_usecases.dart' as event_spg_usecase;
import 'event_spg_event.dart';
import 'event_spg_state.dart';

class EventSpgBloc extends Bloc<EventSpgEvent, EventSpgState> {
  final spg_usecase.GetActiveSpgs getActiveSpgs;
  final event_spg_usecase.GetEventSpgs getEventSpgs;
  final spb_usecase.GetAllSpbs getAllSpbs;
  final event_spg_usecase.AssignSpgToEvent assignSpgToEvent;
  final event_spg_usecase.RemoveSpgFromEvent removeSpgFromEvent;

  EventSpgBloc({
    required this.getActiveSpgs,
    required this.getEventSpgs,
    required this.getAllSpbs,
    required this.assignSpgToEvent,
    required this.removeSpgFromEvent,
  }) : super(EventSpgInitial()) {
    on<LoadAvailableSpgs>(_onLoadAvailableSpgs);
    on<AssignSpg>(_onAssignSpg);
    on<UnassignSpg>(_onUnassignSpg);
    on<SaveAllAssignedSpgs>(_onSaveAllAssignedSpgs);
  }

  Future<void> _onLoadAvailableSpgs(
    LoadAvailableSpgs event,
    Emitter<EventSpgState> emit,
  ) async {
    try {
      emit(EventSpgLoading());
      final availableSpgs = await getActiveSpgs();
      final assignedSpgs = await getEventSpgs(event.eventId);
      final spbs = await getAllSpbs();
      emit(
        AvailableSpgsLoaded(
          spgs: availableSpgs,
          assignedSpgs: assignedSpgs,
          spbs: spbs,
        ),
      );
    } catch (e) {
      emit(EventSpgError(message: e.toString()));
    }
  }

  Future<void> _onAssignSpg(
    AssignSpg event,
    Emitter<EventSpgState> emit,
  ) async {
    try {
      emit(EventSpgLoading());
      await assignSpgToEvent(
        event_spg_usecase.AssignSpgToEventParams(
          eventId: event.eventId,
          spgId: event.spgId,
          spbId: event.spbId,
        ),
      );
      final availableSpgs = await getActiveSpgs();
      final assignedSpgs = await getEventSpgs(event.eventId);
      final spbs = await getAllSpbs();
      emit(
        AvailableSpgsLoaded(
          spgs: availableSpgs,
          assignedSpgs: assignedSpgs,
          spbs: spbs,
        ),
      );
    } catch (e) {
      emit(EventSpgError(message: e.toString()));
    }
  }

  Future<void> _onUnassignSpg(
    UnassignSpg event,
    Emitter<EventSpgState> emit,
  ) async {
    try {
      emit(EventSpgLoading());
      await removeSpgFromEvent(event.eventSpgId);
      emit(SpgUnassigned());
    } catch (e) {
      emit(EventSpgError(message: e.toString()));
    }
  }

  Future<void> _onSaveAllAssignedSpgs(
    SaveAllAssignedSpgs event,
    Emitter<EventSpgState> emit,
  ) async {
    try {
      emit(EventSpgLoading());
      for (final spg in event.assignedSpgs) {
        await assignSpgToEvent(
          event_spg_usecase.AssignSpgToEventParams(
            eventId: event.eventId,
            spgId: spg.spgId,
            spbId: spg.spbId,
          ),
        );
      }
      emit(AllSpgsSaved());
    } catch (e) {
      emit(EventSpgError(message: e.toString()));
    }
  }
}
