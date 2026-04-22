import '../../domain/entities/event_spg_entity.dart';
import '../../domain/repositories/event_spg_repository.dart';

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

  Future<void> call(AssignSpgToEventParams params) async {
    await eventSpgRepository.create(
      EventSpgEntity(
        id: '',
        eventId: params.eventId,
        spgId: params.spgId,
        spbId: params.spbId,
      ),
    );
  }
}

class RemoveSpgFromEvent {
  final EventSpgRepository eventSpgRepository;

  RemoveSpgFromEvent(this.eventSpgRepository);

  Future<void> call(String id) async {
    await eventSpgRepository.delete(id);
  }
}

class GetSpgsByEvent {
  final EventSpgRepository repository;

  GetSpgsByEvent(this.repository);

  Future<List<EventSpgEntity>> call(String eventId) async {
    return await repository.getByEvent(eventId);
  }
}

class GetEventSpgs {
  final EventSpgRepository repository;

  GetEventSpgs(this.repository);

  Future<List<EventSpgEntity>> call(String eventId) async {
    return await repository.getByEvent(eventId);
  }
}

class UpdateEventSpg {
  final EventSpgRepository repository;

  UpdateEventSpg(this.repository);

  Future<EventSpgEntity> call(EventSpgEntity eventSpg) async {
    return await repository.update(eventSpg);
  }
}
