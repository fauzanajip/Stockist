import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/event_product_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

class AssignProductToEventParams {
  final String eventId;
  final String productId;
  final double price;

  AssignProductToEventParams({
    required this.eventId,
    required this.productId,
    required this.price,
  });
}

class AssignProductToEvent {
  final EventProductRepository eventProductRepository;

  AssignProductToEvent(this.eventProductRepository);

  Future<Either<Failure, void>> call(AssignProductToEventParams params) async {
    return await eventProductRepository.create(
      EventProductEntity(
        id: '',
        eventId: params.eventId,
        productId: params.productId,
        price: params.price,
      ),
    ).then((either) {
      return either.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    });
  }
}

class RemoveProductFromEvent {
  final EventProductRepository eventProductRepository;

  RemoveProductFromEvent(this.eventProductRepository);

  Future<Either<Failure, void>> call(String id) async {
    return await eventProductRepository.delete(id);
  }
}

class GetProductsByEvent {
  final EventProductRepository repository;

  GetProductsByEvent(this.repository);

  Future<Either<Failure, List<EventProductEntity>>> call(String eventId) async {
    return await repository.getByEvent(eventId);
  }
}
