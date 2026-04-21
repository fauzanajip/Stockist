import 'package:equatable/equatable.dart';
import '../../../domain/entities/event_spg_entity.dart';

abstract class EventSpgEvent extends Equatable {
  const EventSpgEvent();

  @override
  List<Object?> get props => [];
}

class LoadAvailableSpgs extends EventSpgEvent {
  final String eventId;

  const LoadAvailableSpgs({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class LoadAssignedSpgs extends EventSpgEvent {
  final String eventId;

  const LoadAssignedSpgs({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class AssignSpg extends EventSpgEvent {
  final String eventId;
  final String spgId;
  final String? spbId;

  const AssignSpg({required this.eventId, required this.spgId, this.spbId});

  @override
  List<Object?> get props => [eventId, spgId, spbId];
}

class UnassignSpg extends EventSpgEvent {
  final String eventSpgId;

  const UnassignSpg({required this.eventSpgId});

  @override
  List<Object?> get props => [eventSpgId];
}

class UpdateEventSpgSpb extends EventSpgEvent {
  final String eventSpgId;
  final String? spbId;

  const UpdateEventSpgSpb({required this.eventSpgId, required this.spbId});

  @override
  List<Object?> get props => [eventSpgId, spbId];
}

class SyncEventSpgs extends EventSpgEvent {
  final String eventId;
  final List<EventSpgEntity> assignedSpgs;

  const SyncEventSpgs({
    required this.eventId,
    required this.assignedSpgs,
  });

  @override
  List<Object?> get props => [eventId, assignedSpgs];
}
