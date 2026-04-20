import 'package:uuid/uuid.dart';
import '../../domain/entities/stock_mutation_entity.dart';
import '../../domain/repositories/stock_mutation_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

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

  Future<Either<Failure, StockMutationEntity>> call(CreateStockMutationParams params) async {
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

  Future<Either<Failure, List<StockMutationEntity>>> call(String eventId) async {
    return await repository.getByEvent(eventId);
  }
}

class GetStockMutationsByEventSpg {
  final StockMutationRepository repository;

  GetStockMutationsByEventSpg(this.repository);

  Future<Either<Failure, List<StockMutationEntity>>> call(String eventId, String spgId) async {
    return await repository.getByEventAndSpg(eventId, spgId);
  }
}

class GetTotalGiven {
  final StockMutationRepository repository;

  GetTotalGiven(this.repository);

  Future<Either<Failure, int>> call(String eventId, String spgId, String productId) async {
    return await repository.getTotalGiven(eventId, spgId, productId);
  }
}

class GetTotalReturn {
  final StockMutationRepository repository;

  GetTotalReturn(this.repository);

  Future<Either<Failure, int>> call(String eventId, String spgId, String productId) async {
    return await repository.getTotalReturn(eventId, spgId, productId);
  }
}
