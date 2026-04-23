import '../../domain/entities/sales_entity.dart';
import '../../domain/repositories/sales_repository.dart';

class CreateOrUpdateSalesParams {
  final String eventId;
  final String spgId;
  final String productId;
  final int qtySold;

  CreateOrUpdateSalesParams({
    required this.eventId,
    required this.spgId,
    required this.productId,
    required this.qtySold,
  });
}

class CreateOrUpdateSales {
  final SalesRepository repository;

  CreateOrUpdateSales(this.repository);

  Future<SalesEntity> call(CreateOrUpdateSalesParams params) async {
    final existing = await repository.getByEventSpgProduct(
      params.eventId,
      params.spgId,
      params.productId,
    );

    if (existing == null) {
      return await repository.create(
        SalesEntity(
          id: '',
          eventId: params.eventId,
          spgId: params.spgId,
          productId: params.productId,
          qtySold: params.qtySold,
          updatedAt: DateTime.now(),
          previousQty: null,
        ),
      );
    } else {
      return await repository.update(
        SalesEntity(
          id: existing.id,
          eventId: params.eventId,
          spgId: params.spgId,
          productId: params.productId,
          qtySold: params.qtySold,
          updatedAt: DateTime.now(),
          previousQty: existing.qtySold,
        ),
      );
    }
  }
}

class GetSalesByEventSpg {
  final SalesRepository repository;

  GetSalesByEventSpg(this.repository);

  Future<List<SalesEntity>> call(String eventId, String spgId) async {
    return await repository.getByEventAndSpg(eventId, spgId);
  }
}

class GetSalesByEvent {
  final SalesRepository repository;

  GetSalesByEvent(this.repository);

  Future<List<SalesEntity>> call(String eventId) async {
    return await repository.getByEvent(eventId);
  }
}

class GetTotalSold {
  final SalesRepository repository;

  GetTotalSold(this.repository);

  Future<int> call(String eventId, String spgId, String productId) async {
    return await repository.getTotalSold(eventId, spgId, productId);
  }
}
