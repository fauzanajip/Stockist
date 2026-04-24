import 'package:equatable/equatable.dart';
import '../../../domain/entities/spg_product_target_entity.dart';

abstract class SpgTargetEvent extends Equatable {
  const SpgTargetEvent();

  @override
  List<Object?> get props => [];
}

class LoadTargetsByEvent extends SpgTargetEvent {
  final String eventId;

  const LoadTargetsByEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class LoadTargetsByEventSpg extends SpgTargetEvent {
  final String eventId;
  final String spgId;

  const LoadTargetsByEventSpg({required this.eventId, required this.spgId});

  @override
  List<Object?> get props => [eventId, spgId];
}

class CreateTarget extends SpgTargetEvent {
  final SpgProductTargetEntity target;

  const CreateTarget({required this.target});

  @override
  List<Object?> get props => [target];
}

class UpdateTarget extends SpgTargetEvent {
  final SpgProductTargetEntity target;

  const UpdateTarget({required this.target});

  @override
  List<Object?> get props => [target];
}

class DeleteTarget extends SpgTargetEvent {
  final String id;

  const DeleteTarget({required this.id});

  @override
  List<Object?> get props => [id];
}

class BulkCreateOrUpdateTargetsEvent extends SpgTargetEvent {
  final List<SpgProductTargetEntity> targets;

  const BulkCreateOrUpdateTargetsEvent({required this.targets});

  @override
  List<Object?> get props => [targets];
}