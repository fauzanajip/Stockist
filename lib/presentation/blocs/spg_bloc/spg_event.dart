import 'package:equatable/equatable.dart';
import '../../../domain/entities/spg_entity.dart';

abstract class SpgEvent extends Equatable {
  const SpgEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllSpqs extends SpgEvent {}

class LoadActiveSpqs extends SpgEvent {}

class CreateNewSpq extends SpgEvent {
  final String name;

  const CreateNewSpq({required this.name});

  @override
  List<Object?> get props => [name];
}

class UpdateSpgEvent extends SpgEvent {
  final SpgEntity spg;

  const UpdateSpgEvent({required this.spg});

  @override
  List<Object?> get props => [spg];
}

class DeleteSpq extends SpgEvent {
  final String id;

  const DeleteSpq({required this.id});

  @override
  List<Object?> get props => [id];
}

class SoftDeleteSpqEvent extends SpgEvent {
  final String id;

  const SoftDeleteSpqEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
