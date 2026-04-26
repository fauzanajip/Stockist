import '../entities/pending_topup_entity.dart';

abstract class PendingTopupRepository {
  Future<List<PendingTopupEntity>> getByEvent(String eventId);
  Future<List<PendingTopupEntity>> getByEventAndSpb(String eventId, String? spbId);
  Future<PendingTopupEntity?> getById(String id);
  Future<PendingTopupEntity> create(PendingTopupEntity entity);
  Future<PendingTopupEntity> update(PendingTopupEntity entity);
  Future<void> delete(String id);
  Future<void> deleteByEvent(String eventId);
}