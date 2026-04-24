import '../entities/spg_product_target_entity.dart';

abstract class SpgProductTargetRepository {
  Future<List<SpgProductTargetEntity>> getByEvent(String eventId);
  Future<List<SpgProductTargetEntity>> getByEventSpg(String eventId, String spgId);
  Future<SpgProductTargetEntity?> getByEventSpgProduct(String eventId, String spgId, String productId);
  Future<SpgProductTargetEntity> create(SpgProductTargetEntity target);
  Future<SpgProductTargetEntity> update(SpgProductTargetEntity target);
  Future<void> delete(String id);
  Future<void> bulkCreateOrUpdate(List<SpgProductTargetEntity> targets);
}