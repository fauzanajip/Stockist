import 'package:equatable/equatable.dart';
import '../../../domain/entities/event_product_entity.dart';

abstract class EventProductEvent extends Equatable {
  const EventProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadAvailableProducts extends EventProductEvent {
  final String eventId;

  const LoadAvailableProducts({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class LoadAssignedProducts extends EventProductEvent {
  final String eventId;

  const LoadAssignedProducts({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class AssignProduct extends EventProductEvent {
  final String eventId;
  final String productId;
  final double price;

  const AssignProduct({
    required this.eventId,
    required this.productId,
    required this.price,
  });

  @override
  List<Object?> get props => [eventId, productId, price];
}

class UnassignProduct extends EventProductEvent {
  final String eventProductId;

  const UnassignProduct({required this.eventProductId});

  @override
  List<Object?> get props => [eventProductId];
}

class UpdateEventProductPrice extends EventProductEvent {
  final String eventProductId;
  final double price;

  const UpdateEventProductPrice({
    required this.eventProductId,
    required this.price,
  });

  @override
  List<Object?> get props => [eventProductId, price];
}

class SyncEventProducts extends EventProductEvent {
  final String eventId;
  final List<EventProductEntity> assignedProducts;

  const SyncEventProducts({
    required this.eventId,
    required this.assignedProducts,
  });

  @override
  List<Object?> get props => [eventId, assignedProducts];
}
