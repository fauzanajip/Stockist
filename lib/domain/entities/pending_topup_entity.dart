import 'package:equatable/equatable.dart';

enum PendingTopupType { initial, topup }

class PendingTopupEntity extends Equatable {
  final String id;
  final String eventId;
  final String? spbId;
  final String spgId;
  final String productId;
  final int qty;
  final PendingTopupType type;
  final bool isChecked;
  final String? stockMutationId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PendingTopupEntity({
    required this.id,
    required this.eventId,
    this.spbId,
    required this.spgId,
    required this.productId,
    required this.qty,
    required this.type,
    required this.isChecked,
    this.stockMutationId,
    required this.createdAt,
    required this.updatedAt,
  });

  PendingTopupEntity copyWith({
    String? id,
    String? eventId,
    String? spbId,
    String? spgId,
    String? productId,
    int? qty,
    PendingTopupType? type,
    bool? isChecked,
    String? stockMutationId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PendingTopupEntity(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      spbId: spbId ?? this.spbId,
      spgId: spgId ?? this.spgId,
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      type: type ?? this.type,
      isChecked: isChecked ?? this.isChecked,
      stockMutationId: stockMutationId ?? this.stockMutationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    eventId,
    spbId,
    spgId,
    productId,
    qty,
    type,
    isChecked,
    stockMutationId,
    createdAt,
    updatedAt,
  ];
}