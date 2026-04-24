import '../../domain/entities/stock_mutation_entity.dart';
import '../../domain/repositories/stock_mutation_repository.dart';

class CreateStockMutationParams {
  final String eventId;
  final String spgId;
  final String productId;
  final int qty;
  final MutationType type;
  final String? note;

  CreateStockMutationParams({
    required this.eventId,
    required this.spgId,
    required this.productId,
    required this.qty,
    required this.type,
    this.note,
  });
}

class CreateStockMutation {
  final StockMutationRepository repository;

  CreateStockMutation(this.repository);

  Future<StockMutationEntity> call(CreateStockMutationParams params) async {
    return await repository.create(
      StockMutationEntity(
        id: '',
        eventId: params.eventId,
        spgId: params.spgId,
        productId: params.productId,
        qty: params.qty,
        type: params.type,
        timestamp: DateTime.now(),
        note: params.note,
      ),
    );
  }
}

class GetStockMutationsByEvent {
  final StockMutationRepository repository;

  GetStockMutationsByEvent(this.repository);

  Future<List<StockMutationEntity>> call(String eventId) async {
    return await repository.getByEvent(eventId);
  }
}

class GetStockMutationsByEventSpg {
  final StockMutationRepository repository;

  GetStockMutationsByEventSpg(this.repository);

  Future<List<StockMutationEntity>> call(String eventId, String spgId) async {
    return await repository.getByEventAndSpg(eventId, spgId);
  }
}

class GetTotalGiven {
  final StockMutationRepository repository;

  GetTotalGiven(this.repository);

  Future<int> call(String eventId, String spgId, String productId) async {
    return await repository.getTotalGiven(eventId, spgId, productId);
  }
}

class GetTotalReturn {
  final StockMutationRepository repository;

  GetTotalReturn(this.repository);

  Future<int> call(String eventId, String spgId, String productId) async {
    return await repository.getTotalReturn(eventId, spgId, productId);
  }
}

class UpdateStockMutationQty {
  final StockMutationRepository repository;

  UpdateStockMutationQty(this.repository);

  Future<StockMutationEntity> call(String id, int qty) async {
    return await repository.update(id, qty);
  }
}

class DeleteStockMutationRecord {
  final StockMutationRepository repository;

  DeleteStockMutationRecord(this.repository);

  Future<void> call(String id) async {
    return await repository.delete(id);
  }
}

class BulkCreateOrUpdateInitialStock {
  final StockMutationRepository repository;

  BulkCreateOrUpdateInitialStock(this.repository);

  Future<void> call(List<BulkInitialParams> params) async {
    return await repository.bulkCreateOrUpdateInitial(params);
  }
}

class GetWarehouseStockByProduct {
  final StockMutationRepository repository;

  GetWarehouseStockByProduct(this.repository);

  Future<int> call(String eventId, String productId) async {
    return await repository.getWarehouseStockByProduct(eventId, productId);
  }
}

class GetDistributedByProduct {
  final StockMutationRepository repository;

  GetDistributedByProduct(this.repository);

  Future<int> call(String eventId, String productId, String excludeSpgId) async {
    return await repository.getDistributedByProduct(eventId, productId, excludeSpgId);
  }
}

class GetReturnsByProduct {
  final StockMutationRepository repository;

  GetReturnsByProduct(this.repository);

  Future<int> call(String eventId, String productId) async {
    return await repository.getReturnsByProduct(eventId, productId);
  }
}
