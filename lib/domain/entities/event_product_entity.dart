import 'package:equatable/equatable.dart';

class EventProductEntity extends Equatable {
  final String id;
  final String eventId;
  final String productId;
  final double price;

  const EventProductEntity({
    required this.id,
    required this.eventId,
    required this.productId,
    required this.price,
  });

  EventProductEntity copyWith({
    String? id,
    String? eventId,
    String? productId,
    double? price,
  }) {
    return EventProductEntity(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      productId: productId ?? this.productId,
      price: price ?? this.price,
    );
  }

  @override
  List<Object?> get props => [id, eventId, productId, price];
}
