import 'package:equatable/equatable.dart';

class SalesEntity extends Equatable {
  final String id;
  final String eventId;
  final String spgId;
  final String productId;
  final int qtySold;
  final DateTime updatedAt;
  final int? previousQty;

  const SalesEntity({
    required this.id,
    required this.eventId,
    required this.spgId,
    required this.productId,
    required this.qtySold,
    required this.updatedAt,
    this.previousQty,
  });

  SalesEntity copyWith({
    String? id,
    String? eventId,
    String? spgId,
    String? productId,
    int? qtySold,
    DateTime? updatedAt,
    int? previousQty,
  }) {
    return SalesEntity(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      spgId: spgId ?? this.spgId,
      productId: productId ?? this.productId,
      qtySold: qtySold ?? this.qtySold,
      updatedAt: updatedAt ?? this.updatedAt,
      previousQty: previousQty ?? this.previousQty,
    );
  }

  @override
  List<Object?> get props => [
    id,
    eventId,
    spgId,
    productId,
    qtySold,
    updatedAt,
    previousQty,
  ];
}
