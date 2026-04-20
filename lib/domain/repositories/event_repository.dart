import '../entities/event_entity.dart';

abstract class EventRepository {
  Future<List<EventEntity>> getAll();
  Future<EventEntity?> getById(String id);
  Future<EventEntity> create(EventEntity event);
  Future<EventEntity> update(EventEntity event);
  Future<void> delete(String id);
  Future<EventEntity> closeEvent(String id);
  Future<EventEntity> reopenEvent(String id);
}
