import 'package:equatable/equatable.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class CreateEventParams extends Equatable {
  final String name;
  final DateTime date;

  const CreateEventParams({
    required this.name,
    required this.date,
  });

  @override
  List<Object?> get props => [name, date];
}

class CreateEvent {
  final EventRepository repository;

  CreateEvent(this.repository);

  Future<Either<Failure, EventEntity>> call(CreateEventParams params) async {
    return await repository.create(
      EventEntity(
        id: '',
        name: params.name,
        date: params.date,
        status: EventStatus.open,
      ),
    );
  }
}

class GetAllEvents {
  final EventRepository repository;

  GetAllEvents(this.repository);

  Future<Either<Failure, List<EventEntity>>> call() async {
    return await repository.getAll();
  }
}

class GetEventById {
  final EventRepository repository;

  GetEventById(this.repository);

  Future<Either<Failure, EventEntity?>> call(String id) async {
    return await repository.getById(id);
  }
}

class CloseEvent {
  final EventRepository repository;

  CloseEvent(this.repository);

  Future<Either<Failure, EventEntity>> call(String id) async {
    return await repository.closeEvent(id);
  }
}

class ReopenEvent {
  final EventRepository repository;

  ReopenEvent(this.repository);

  Future<Either<Failure, EventEntity>> call(String id) async {
    return await repository.reopenEvent(id);
  }
}
