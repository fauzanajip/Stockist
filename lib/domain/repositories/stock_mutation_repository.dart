import '../entities/stock_mutation_entity.dart';

abstract class StockMutationRepository {
  Future<List<StockMutationEntity>> getByEvent(String eventId);
  Future<List<StockMutationEntity>> getByEventAndSpg(
    String eventId,
    String spgId,
  );
  Future<List<StockMutationEntity>> getByEventSpgProduct(
    String eventId,
    String spgId,
    String productId,
  );
  Future<StockMutationEntity> create(StockMutationEntity mutation);
  Future<StockMutationEntity> update(String id, int qty);
  Future<void> delete(String id);
  Future<int> getTotalGiven(String eventId, String spgId, String productId);
  Future<int> getTotalReturn(String eventId, String spgId, String productId);
}
