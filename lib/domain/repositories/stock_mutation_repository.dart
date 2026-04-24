import '../entities/stock_mutation_entity.dart';

class BulkInitialParams {
  final String eventId;
  final String spgId;
  final String productId;
  final int qty;

  const BulkInitialParams({
    required this.eventId,
    required this.spgId,
    required this.productId,
    required this.qty,
  });
}

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
  Future<void> bulkCreateOrUpdateInitial(List<BulkInitialParams> params);
  Future<int> getWarehouseStockByProduct(String eventId, String productId);
  Future<int> getDistributedByProduct(String eventId, String productId, String excludeSpgId);
  Future<int> getReturnsByProduct(String eventId, String productId);
}
