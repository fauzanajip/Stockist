import '../entities/event_product_entity.dart';

abstract class EventProductRepository {
  Future<List<EventProductEntity>> getByEvent(String eventId);
  Future<EventProductEntity?> getById(String id);
  Future<EventProductEntity> create(EventProductEntity eventProduct);
  Future<EventProductEntity> update(EventProductEntity eventProduct);
  Future<void> updatePrice(String id, double price);
  Future<void> delete(String id);
  Future<void> deleteByEvent(String eventId);
}
