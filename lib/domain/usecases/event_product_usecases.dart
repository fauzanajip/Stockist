import '../../domain/entities/event_product_entity.dart';
import '../../domain/repositories/event_product_repository.dart';

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

  Future<void> call(AssignProductToEventParams params) async {
    await eventProductRepository.create(
      EventProductEntity(
        id: '',
        eventId: params.eventId,
        productId: params.productId,
        price: params.price,
      ),
    );
  }
}

class RemoveProductFromEvent {
  final EventProductRepository eventProductRepository;

  RemoveProductFromEvent(this.eventProductRepository);

  Future<void> call(String id) async {
    await eventProductRepository.delete(id);
  }
}

class GetProductsByEvent {
  final EventProductRepository repository;

  GetProductsByEvent(this.repository);

  Future<List<EventProductEntity>> call(String eventId) async {
    return await repository.getByEvent(eventId);
  }
}

class GetEventProducts {
  final EventProductRepository repository;

  GetEventProducts(this.repository);

  Future<List<EventProductEntity>> call(String eventId) async {
    return await repository.getByEvent(eventId);
  }
}

class UpdateEventProductPrice {
  final EventProductRepository repository;

  UpdateEventProductPrice(this.repository);

  Future<void> call({
    required String eventProductId,
    required double price,
  }) async {
    await repository.updatePrice(eventProductId, price);
  }
}
