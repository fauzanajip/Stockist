import '../../domain/entities/pending_topup_entity.dart';
import '../../domain/repositories/pending_topup_repository.dart';

class GetPendingTopupsByEvent {
  final PendingTopupRepository repository;

  GetPendingTopupsByEvent(this.repository);

  Future<List<PendingTopupEntity>> call(String eventId) async {
    return await repository.getByEvent(eventId);
  }
}

class GetPendingTopupsByEventAndSpb {
  final PendingTopupRepository repository;

  GetPendingTopupsByEventAndSpb(this.repository);

  Future<List<PendingTopupEntity>> call(String eventId, String? spbId) async {
    return await repository.getByEventAndSpb(eventId, spbId);
  }
}

class CreatePendingTopupUsecase {
  final PendingTopupRepository repository;

  CreatePendingTopupUsecase(this.repository);

  Future<PendingTopupEntity> call(PendingTopupEntity entity) async {
    return await repository.create(entity);
  }
}

class UpdatePendingTopupUsecase {
  final PendingTopupRepository repository;

  UpdatePendingTopupUsecase(this.repository);

  Future<PendingTopupEntity> call(PendingTopupEntity entity) async {
    return await repository.update(entity);
  }
}

class DeletePendingTopupUsecase {
  final PendingTopupRepository repository;

  DeletePendingTopupUsecase(this.repository);

  Future<void> call(String id) async {
    await repository.delete(id);
  }
}

class GetPendingTopupById {
  final PendingTopupRepository repository;

  GetPendingTopupById(this.repository);

  Future<PendingTopupEntity?> call(String id) async {
    return await repository.getById(id);
  }
}