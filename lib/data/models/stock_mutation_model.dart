import '../../domain/entities/stock_mutation_entity.dart';
import '../data_sources/database_helper.dart';

class StockMutationModel extends StockMutationEntity {
  final DateTime createdAt;

  const StockMutationModel({
    required super.id,
    required super.eventId,
    required super.spgId,
    required super.productId,
    required super.qty,
    required super.type,
    required super.timestamp,
    super.note,
    required this.createdAt,
  });

  factory StockMutationModel.fromEntity(StockMutationEntity entity) {
    return StockMutationModel(
      id: entity.id,
      eventId: entity.eventId,
      spgId: entity.spgId,
      productId: entity.productId,
      qty: entity.qty,
      type: entity.type,
      timestamp: entity.timestamp,
      note: entity.note,
      createdAt: DateTime.now(),
    );
  }

  factory StockMutationModel.fromMap(Map<String, dynamic> map) {
    return StockMutationModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      spgId: map['spg_id'] as String,
      productId: map['product_id'] as String,
      qty: map['qty'] as int,
      type: MutationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MutationType.initial,
      ),
      timestamp: DatabaseHelper.stringToDateTime(map['timestamp'] as String),
      note: map['note'] as String?,
      createdAt: DatabaseHelper.stringToDateTime(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'spg_id': spgId,
      'product_id': productId,
      'qty': qty,
      'type': type.name,
      'timestamp': DatabaseHelper.dateTimeToString(timestamp),
      'note': note,
      'created_at': DatabaseHelper.dateTimeToString(createdAt),
    };
  }

  StockMutationModel copyWith({
    String? id,
    String? eventId,
    String? spgId,
    String? productId,
    int? qty,
    MutationType? type,
    DateTime? timestamp,
    String? note,
    DateTime? createdAt,
  }) {
    return StockMutationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      spgId: spgId ?? this.spgId,
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [...super.props, createdAt];
}
