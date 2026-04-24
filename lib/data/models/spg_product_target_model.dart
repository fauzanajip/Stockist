import '../../domain/entities/spg_product_target_entity.dart';
import '../data_sources/database_helper.dart';

class SpgProductTargetModel extends SpgProductTargetEntity {
  final DateTime createdAt;
  final DateTime updatedAt;

  const SpgProductTargetModel({
    required super.id,
    required super.eventId,
    required super.spgId,
    required super.productId,
    required super.targetQty,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SpgProductTargetModel.fromEntity(SpgProductTargetEntity entity) {
    return SpgProductTargetModel(
      id: entity.id,
      eventId: entity.eventId,
      spgId: entity.spgId,
      productId: entity.productId,
      targetQty: entity.targetQty,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory SpgProductTargetModel.fromMap(Map<String, dynamic> map) {
    return SpgProductTargetModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      spgId: map['spg_id'] as String,
      productId: map['product_id'] as String,
      targetQty: map['target_qty'] as int,
      createdAt: DatabaseHelper.stringToDateTime(map['created_at'] as String),
      updatedAt: DatabaseHelper.stringToDateTime(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'spg_id': spgId,
      'product_id': productId,
      'target_qty': targetQty,
      'created_at': DatabaseHelper.dateTimeToString(createdAt),
      'updated_at': DatabaseHelper.dateTimeToString(updatedAt),
    };
  }

  SpgProductTargetModel copyWithModel({
    String? id,
    String? eventId,
    String? spgId,
    String? productId,
    int? targetQty,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SpgProductTargetModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      spgId: spgId ?? this.spgId,
      productId: productId ?? this.productId,
      targetQty: targetQty ?? this.targetQty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [...super.props, createdAt, updatedAt];
}