import 'package:equatable/equatable.dart';
import '../../domain/entities/event_entity.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventsLoaded extends EventState {
  final List<EventEntity> events;

  const EventsLoaded({required this.events});

  @override
  List<Object?> get props => [events];
}

class EventDetailLoaded extends EventState {
  final EventEntity event;

  const EventDetailLoaded({required this.event});

  @override
  List<Object?> get props => [event];
}

class EventCreated extends EventState {
  final EventEntity event;

  const EventCreated({required this.event});

  @override
  List<Object?> get props => [event];
}

class EventClosed extends EventState {
  final EventEntity event;

  const EventClosed({required this.event});

  @override
  List<Object?> get props => [event];
}

class EventReopened extends EventState {
  final EventEntity event;

  const EventReopened({required this.event});

  @override
  List<Object?> get props => [event];
}

class EventError extends EventState {
  final String message;

  const EventError({required this.message});

  @override
  List<Object?> get props => [message];
}
