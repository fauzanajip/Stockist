import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/event_usecases.dart';
import '../../../data/data_sources/database_helper.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final GetAllEvents getAllEvents;
  final GetEventById getEventById;
  final CreateEvent createEvent;
  final CloseEvent closeEvent;
  final ReopenEvent reopenEvent;
  final SetEventActiveUseCase setEventActive;
  final DatabaseHelper databaseHelper;

  EventBloc({
    required this.getAllEvents,
    required this.getEventById,
    required this.createEvent,
    required this.closeEvent,
    required this.reopenEvent,
    required this.setEventActive,
    required this.databaseHelper,
  }) : super(EventInitial()) {
    on<LoadAllEvents>(_onLoadAllEvents);
    on<LoadEventById>(_onLoadEventById);
    on<CreateNewEvent>(_onCreateNewEvent);
    on<CloseCurrentEvent>(_onCloseCurrentEvent);
    on<ReopenCurrentEvent>(_onReopenCurrentEvent);
    on<SetEventActive>(_onSetEventActive);
    on<ResetAllData>(_onResetAllData);
  }

  Future<void> _onResetAllData(
    ResetAllData event,
    Emitter<EventState> emit,
  ) async {
    try {
      emit(EventLoading());
      await databaseHelper.clearAllData();
      add(LoadAllEvents());
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onLoadAllEvents(
    LoadAllEvents event,
    Emitter<EventState> emit,
  ) async {
    try {
      emit(EventLoading());
      final events = await getAllEvents();
      emit(EventsLoaded(events: events));
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onLoadEventById(
    LoadEventById event,
    Emitter<EventState> emit,
  ) async {
    try {
      emit(EventLoading());
      final eventEntity = await getEventById(event.id);
      if (eventEntity != null) {
        emit(EventDetailLoaded(event: eventEntity));
      } else {
        emit(const EventError(message: 'Event not found'));
      }
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onCreateNewEvent(
    CreateNewEvent event,
    Emitter<EventState> emit,
  ) async {
    try {
      emit(EventLoading());
      final newEvent = await createEvent(
        CreateEventParams(name: event.name, date: event.date),
      );

      // Auto-activate the newly created event
      await setEventActive(newEvent.id);

      emit(EventCreated(event: newEvent));
      add(LoadAllEvents());
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onCloseCurrentEvent(
    CloseCurrentEvent event,
    Emitter<EventState> emit,
  ) async {
    try {
      final closedEvent = await closeEvent(event.id);
      emit(EventClosed(event: closedEvent));
      add(LoadAllEvents());
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onReopenCurrentEvent(
    ReopenCurrentEvent event,
    Emitter<EventState> emit,
  ) async {
    try {
      final reopenedEvent = await reopenEvent(event.id);
      emit(EventReopened(event: reopenedEvent));
      add(LoadAllEvents());
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }

  Future<void> _onSetEventActive(
    SetEventActive event,
    Emitter<EventState> emit,
  ) async {
    try {
      await setEventActive(event.id);
      add(LoadAllEvents());
    } catch (e) {
      emit(EventError(message: e.toString()));
    }
  }
}
