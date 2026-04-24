import 'package:equatable/equatable.dart';
import '../../../domain/entities/spg_product_target_entity.dart';

abstract class SpgTargetState extends Equatable {
  const SpgTargetState();

  @override
  List<Object?> get props => [];
}

class SpgTargetInitial extends SpgTargetState {}

class SpgTargetLoading extends SpgTargetState {}

class SpgTargetsLoaded extends SpgTargetState {
  final List<SpgProductTargetEntity> targets;

  const SpgTargetsLoaded({required this.targets});

  @override
  List<Object?> get props => [targets];
}

class SpgTargetCreated extends SpgTargetState {
  final SpgProductTargetEntity target;

  const SpgTargetCreated({required this.target});

  @override
  List<Object?> get props => [target];
}

class SpgTargetUpdated extends SpgTargetState {
  final SpgProductTargetEntity target;

  const SpgTargetUpdated({required this.target});

  @override
  List<Object?> get props => [target];
}

class SpgTargetDeleted extends SpgTargetState {}

class SpgTargetsBulkSaved extends SpgTargetState {}

class SpgTargetError extends SpgTargetState {
  final String message;

  const SpgTargetError({required this.message});

  @override
  List<Object?> get props => [message];
}