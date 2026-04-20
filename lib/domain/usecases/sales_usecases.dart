import 'package:uuid/uuid.dart';
import '../../domain/entities/sales_entity.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

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

  Future<Either<Failure, SalesEntity>> call(CreateOrUpdateSalesParams params) async {
    final existingResult = await repository.getByEventSpgProduct(
      params.eventId,
      params.spgId,
      params.productId,
    );

    return existingResult.fold(
      (failure) => Left(failure),
      (existing) {
        if (existing == null) {
          return repository.create(
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
          return repository.update(
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
      },
    );
  }
}

class GetSalesByEventSpg {
  final SalesRepository repository;

  GetSalesByEventSpg(this.repository);

  Future<Either<Failure, List<SalesEntity>>> call(String eventId, String spgId) async {
    return await repository.getByEventAndSpg(eventId, spgId);
  }
}
