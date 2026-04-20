import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/event_usecases.dart';
import 'event_bloc.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final GetAllEvents getAllEvents;
  final GetEventById getEventById;
  final CreateEvent createEvent;
  final CloseEvent closeEvent;
  final ReopenEvent reopenEvent;

  EventBloc({
    required this.getAllEvents,
    required this.getEventById,
    required this.createEvent,
    required this.closeEvent,
    required this.reopenEvent,
  }) : super(EventInitial()) {
    on<LoadAllEvents>(_onLoadAllEvents);
    on<LoadEventById>(_onLoadEventById);
    on<CreateNewEvent>(_onCreateNewEvent);
    on<CloseCurrentEvent>(_onCloseCurrentEvent);
    on<ReopenCurrentEvent>(_onReopenCurrentEvent);
  }

  Future<void> _onLoadAllEvents(
    LoadAllEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    
    final result = await getAllEvents();
    
    result.fold(
      (failure) => emit(EventError(message: failure.message)),
      (events) => emit(EventsLoaded(events: events)),
    );
  }

  Future<void> _onLoadEventById(
    LoadEventById event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    
    final result = await getEventById(event.id);
    
    result.fold(
      (failure) => emit(EventError(message: failure.message)),
      (eventEntity) {
        if (eventEntity != null) {
          emit(EventDetailLoaded(event: eventEntity));
        } else {
          emit(const EventError(message: 'Event not found'));
        }
      },
    );
  }

  Future<void> _onCreateNewEvent(
    CreateNewEvent event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    
    final result = await createEvent(
      CreateEventParams(name: event.name, date: event.date),
    );
    
    result.fold(
      (failure) => emit(EventError(message: failure.message)),
      (newEvent) {
        emit(EventCreated(event: newEvent));
        add(LoadAllEvents());
      },
    );
  }

  Future<void> _onCloseCurrentEvent(
    CloseCurrentEvent event,
    Emitter<EventState> emit,
  ) async {
    final result = await closeEvent(event.id);
    
    result.fold(
      (failure) => emit(EventError(message: failure.message)),
      (closedEvent) => emit(EventClosed(event: closedEvent)),
    );
  }

  Future<void> _onReopenCurrentEvent(
    ReopenCurrentEvent event,
    Emitter<EventState> emit,
  ) async {
    final result = await reopenEvent(event.id);
    
    result.fold(
      (failure) => emit(EventError(message: failure.message)),
      (reopenedEvent) => emit(EventReopened(event: reopenedEvent)),
    );
  }
}
