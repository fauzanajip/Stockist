import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  final String message;
  final Exception? exception;

  const Failure({required this.message, this.exception});

  @override
  List<Object?> get props => [message, exception];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message, super.exception});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message});
}
