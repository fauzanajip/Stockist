import '../../domain/entities/pending_topup_entity.dart';

class PendingTopupModel {
  final String id;
  final String eventId;
  final String? spbId;
  final String spgId;
  final String productId;
  final int qty;
  final String type;
  final int isChecked;
  final String? stockMutationId;
  final DateTime createdAt;
  final DateTime updatedAt;

  PendingTopupModel({
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

  factory PendingTopupModel.fromMap(Map<String, dynamic> map) {
    return PendingTopupModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      spbId: map['spb_id'] as String?,
      spgId: map['spg_id'] as String,
      productId: map['product_id'] as String,
      qty: map['qty'] as int,
      type: map['type'] as String,
      isChecked: map['is_checked'] as int,
      stockMutationId: map['stock_mutation_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'spb_id': spbId,
      'spg_id': spgId,
      'product_id': productId,
      'qty': qty,
      'type': type,
      'is_checked': isChecked,
      'stock_mutation_id': stockMutationId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PendingTopupEntity toEntity() {
    return PendingTopupEntity(
      id: id,
      eventId: eventId,
      spbId: spbId,
      spgId: spgId,
      productId: productId,
      qty: qty,
      type: type == 'initial' ? PendingTopupType.initial : PendingTopupType.topup,
      isChecked: isChecked == 1,
      stockMutationId: stockMutationId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory PendingTopupModel.fromEntity(PendingTopupEntity entity) {
    return PendingTopupModel(
      id: entity.id,
      eventId: entity.eventId,
      spbId: entity.spbId,
      spgId: entity.spgId,
      productId: entity.productId,
      qty: entity.qty,
      type: entity.type == PendingTopupType.initial ? 'initial' : 'topup',
      isChecked: entity.isChecked ? 1 : 0,
      stockMutationId: entity.stockMutationId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}