import 'package:equatable/equatable.dart';
import '../../domain/entities/spg_entity.dart';

abstract class SpgState extends Equatable {
  const SpgState();

  @override
  List<Object?> get props => [];
}

class SpgInitial extends SpgState {}

class SpgLoading extends SpgState {}

class SpqsLoaded extends SpgState {
  final List<SpgEntity> spqs;

  const SpqsLoaded({required this.spqs});

  @override
  List<Object?> get props => [spqs];
}

class SpqCreated extends SpgState {}

class SpqDeleted extends SpgState {}

class SpgError extends SpgState {
  final String message;

  const SpgError({required this.message});

  @override
  List<Object?> get props => [message];
}
