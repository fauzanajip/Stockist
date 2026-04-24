import 'package:equatable/equatable.dart';

class SpgProductTargetEntity extends Equatable {
  final String id;
  final String eventId;
  final String spgId;
  final String productId;
  final int targetQty;

  const SpgProductTargetEntity({
    required this.id,
    required this.eventId,
    required this.spgId,
    required this.productId,
    required this.targetQty,
  });

  SpgProductTargetEntity copyWith({
    String? id,
    String? eventId,
    String? spgId,
    String? productId,
    int? targetQty,
  }) {
    return SpgProductTargetEntity(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      spgId: spgId ?? this.spgId,
      productId: productId ?? this.productId,
      targetQty: targetQty ?? this.targetQty,
    );
  }

  @override
  List<Object?> get props => [id, eventId, spgId, productId, targetQty];
}