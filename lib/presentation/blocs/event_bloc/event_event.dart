import 'package:equatable/equatable.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllEvents extends EventEvent {}

class LoadEventById extends EventEvent {
  final String id;

  const LoadEventById({required this.id});

  @override
  List<Object?> get props => [id];
}

class CreateNewEvent extends EventEvent {
  final String name;
  final DateTime date;

  const CreateNewEvent({required this.name, required this.date});

  @override
  List<Object?> get props => [name, date];
}

class CloseCurrentEvent extends EventEvent {
  final String id;

  const CloseCurrentEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class ReopenCurrentEvent extends EventEvent {
  final String id;

  const ReopenCurrentEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class SetEventActive extends EventEvent {
  final String id;

  const SetEventActive({required this.id});

  @override
  List<Object?> get props => [id];
}

class ResetAllData extends EventEvent {}
