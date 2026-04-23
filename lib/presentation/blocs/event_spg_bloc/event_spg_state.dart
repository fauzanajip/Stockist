import 'package:equatable/equatable.dart';
import '../../../domain/entities/spg_entity.dart';
import '../../../domain/entities/spb_entity.dart';
import '../../../domain/entities/event_spg_entity.dart';

abstract class EventSpgState extends Equatable {
  const EventSpgState();

  @override
  List<Object?> get props => [];
}

class EventSpgInitial extends EventSpgState {}

class EventSpgLoading extends EventSpgState {}

class AvailableSpgsLoaded extends EventSpgState {
  final List<SpgEntity> spgs;
  final List<EventSpgEntity> assignedSpgs;
  final List<SpbEntity> spbs;

  const AvailableSpgsLoaded({
    required this.spgs,
    required this.assignedSpgs,
    required this.spbs,
  });

  @override
  List<Object?> get props => [spgs, assignedSpgs, spbs];
}

class AssignedSpgsLoaded extends EventSpgState {
  final List<EventSpgEntity> spgs;

  const AssignedSpgsLoaded({required this.spgs});

  @override
  List<Object?> get props => [spgs];
}

class SpgAssigned extends EventSpgState {
  final EventSpgEntity spg;

  const SpgAssigned({required this.spg});

  @override
  List<Object?> get props => [spg];
}

class SpgUnassigned extends EventSpgState {}

class AllSpgsSaved extends EventSpgState {}

class EventSpgError extends EventSpgState {
  final String message;

  const EventSpgError({required this.message});

  @override
  List<Object?> get props => [message];
}
