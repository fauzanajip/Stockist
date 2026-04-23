import 'package:equatable/equatable.dart';
import '../../../domain/entities/spb_entity.dart';

abstract class SpbState extends Equatable {
  const SpbState();

  @override
  List<Object?> get props => [];
}

class SpbInitial extends SpbState {}

class SpbLoading extends SpbState {}

class SpbsLoaded extends SpbState {
  final List<SpbEntity> spbs;

  const SpbsLoaded({required this.spbs});

  @override
  List<Object?> get props => [spbs];
}

class SpbCreated extends SpbState {
  final SpbEntity spb;

  const SpbCreated({required this.spb});

  @override
  List<Object?> get props => [spb];
}

class SpbDeleted extends SpbState {}

class SpbError extends SpbState {
  final String message;

  const SpbError({required this.message});

  @override
  List<Object?> get props => [message];
}
