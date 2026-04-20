import '../../domain/entities/sales_entity.dart';
import '../data_sources/database_helper.dart';

class SalesModel extends SalesEntity {
  final DateTime createdAt;

  const SalesModel({
    required super.id,
    required super.eventId,
    required super.spgId,
    required super.productId,
    required super.qtySold,
    required super.updatedAt,
    super.previousQty,
    required this.createdAt,
  });

  factory SalesModel.fromEntity(SalesEntity entity) {
    return SalesModel(
      id: entity.id,
      eventId: entity.eventId,
      spgId: entity.spgId,
      productId: entity.productId,
      qtySold: entity.qtySold,
      updatedAt: entity.updatedAt,
      previousQty: entity.previousQty,
      createdAt: DateTime.now(),
    );
  }

  factory SalesModel.fromMap(Map<String, dynamic> map) {
    return SalesModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      spgId: map['spg_id'] as String,
      productId: map['product_id'] as String,
      qtySold: map['qty_sold'] as int,
      updatedAt: DatabaseHelper.stringToDateTime(map['updated_at'] as String),
      previousQty: map['previous_qty'] as int?,
      createdAt: DatabaseHelper.stringToDateTime(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'spg_id': spgId,
      'product_id': productId,
      'qty_sold': qtySold,
      'previous_qty': previousQty,
      'updated_at': DatabaseHelper.dateTimeToString(updatedAt),
      'created_at': DatabaseHelper.dateTimeToString(createdAt),
    };
  }

  SalesModel copyWith({
    String? id,
    String? eventId,
    String? spgId,
    String? productId,
    int? qtySold,
    DateTime? updatedAt,
    int? previousQty,
    DateTime? createdAt,
  }) {
    return SalesModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      spgId: spgId ?? this.spgId,
      productId: productId ?? this.productId,
      qtySold: qtySold ?? this.qtySold,
      updatedAt: updatedAt ?? this.updatedAt,
      previousQty: previousQty ?? this.previousQty,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [...super.props, createdAt];
}
