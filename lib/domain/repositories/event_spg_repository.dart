import '../entities/event_spg_entity.dart';

abstract class EventSpgRepository {
  Future<List<EventSpgEntity>> getByEvent(String eventId);
  Future<EventSpgEntity?> getById(String id);
  Future<EventSpgEntity> create(EventSpgEntity eventSpg);
  Future<EventSpgEntity> update(EventSpgEntity eventSpg);
  Future<void> delete(String id);
  Future<void> deleteByEvent(String eventId);
  Future<String?> getSpbIdBySpg(String eventId, String spgId);
}
