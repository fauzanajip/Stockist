import 'package:equatable/equatable.dart';

enum MutationType { initial, topup, returnMutation, distributorToEvent }

class StockMutationEntity extends Equatable {
  final String id;
  final String eventId;
  final String spgId;
  final String productId;
  final int qty;
  final MutationType type;
  final DateTime timestamp;
  final String? note;

  const StockMutationEntity({
    required this.id,
    required this.eventId,
    required this.spgId,
    required this.productId,
    required this.qty,
    required this.type,
    required this.timestamp,
    this.note,
  });

  StockMutationEntity copyWith({
    String? id,
    String? eventId,
    String? spgId,
    String? productId,
    int? qty,
    MutationType? type,
    DateTime? timestamp,
    String? note,
  }) {
    return StockMutationEntity(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      spgId: spgId ?? this.spgId,
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, eventId, spgId, productId, qty, type, timestamp, note];
}
