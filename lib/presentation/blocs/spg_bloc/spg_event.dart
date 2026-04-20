import 'package:equatable/equatable.dart';

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

class DeleteSpq extends SpgEvent {
  final String id;

  const DeleteSpq({required this.id});

  @override
  List<Object?> get props => [id];
}

class SoftDeleteSpq extends SpgEvent {
  final String id;

  const SoftDeleteSpq({required this.id});

  @override
  List<Object?> get props => [id];
}
