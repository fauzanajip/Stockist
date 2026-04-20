import 'package:uuid/uuid.dart';
import '../../domain/entities/event_spg_entity.dart';
import '../../domain/repositories/event_spg_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class AssignSpgToEventParams {
  final String eventId;
  final String spgId;
  final String? spbId;

  AssignSpgToEventParams({
    required this.eventId,
    required this.spgId,
    this.spbId,
  });
}

class AssignSpgToEvent {
  final EventSpgRepository eventSpgRepository;

  AssignSpgToEvent(this.eventSpgRepository);

  Future<Either<Failure, void>> call(AssignSpgToEventParams params) async {
    return await eventSpgRepository.create(
      EventSpgEntity(
        id: '',
        eventId: params.eventId,
        spgId: params.spgId,
        spbId: params.spbId,
      ),
    ).then((either) {
      return either.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    });
  }
}

class RemoveSpgFromEvent {
  final EventSpgRepository eventSpgRepository;

  RemoveSpgFromEvent(this.eventSpgRepository);

  Future<Either<Failure, void>> call(String id) async {
    return await eventSpgRepository.delete(id);
  }
}

class GetSpgsByEvent {
  final EventSpgRepository repository;

  GetSpgsByEvent(this.repository);

  Future<Either<Failure, List<EventSpgEntity>>> call(String eventId) async {
    return await repository.getByEvent(eventId);
  }
}
