import 'package:equatable/equatable.dart';

abstract class SpbEvent extends Equatable {
  const SpbEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllSpbs extends SpbEvent {}

class CreateSpbEvent extends SpbEvent {
  final String name;

  const CreateSpbEvent({required this.name});

  @override
  List<Object?> get props => [name];
}

class DeleteSpbEvent extends SpbEvent {
  final String spbId;

  const DeleteSpbEvent({required this.spbId});

  @override
  List<Object?> get props => [spbId];
}