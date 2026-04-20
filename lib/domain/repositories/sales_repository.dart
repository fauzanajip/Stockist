import '../entities/sales_entity.dart';

abstract class SalesRepository {
  Future<List<SalesEntity>> getByEvent(String eventId);
  Future<List<SalesEntity>> getByEventAndSpg(String eventId, String spgId);
  Future<SalesEntity?> getByEventSpgProduct(String eventId, String spgId, String productId);
  Future<SalesEntity> create(SalesEntity sales);
  Future<SalesEntity> update(SalesEntity sales);
  Future<int> getTotalSold(String eventId, String spgId, String productId);
}
