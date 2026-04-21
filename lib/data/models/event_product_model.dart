import 'package:uuid/uuid.dart';
import '../../domain/entities/event_product_entity.dart';
import '../data_sources/database_helper.dart';

class EventProductModel extends EventProductEntity {
  final DateTime createdAt;

  const EventProductModel({
    required super.id,
    required super.eventId,
    required super.productId,
    required super.price,
    required this.createdAt,
  });

  factory EventProductModel.fromEntity(EventProductEntity entity) {
    final uuid = const Uuid().v4();
    return EventProductModel(
      id: entity.id.isEmpty ? uuid : entity.id,
      eventId: entity.eventId,
      productId: entity.productId,
      price: entity.price,
      createdAt: DateTime.now(),
    );
  }

  factory EventProductModel.fromMap(Map<String, dynamic> map) {
    return EventProductModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      productId: map['product_id'] as String,
      price: (map['price'] as num).toDouble(),
      createdAt: DatabaseHelper.stringToDateTime(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'product_id': productId,
      'price': price,
      'created_at': DatabaseHelper.dateTimeToString(createdAt),
    };
  }

  @override
  EventProductModel copyWith({
    String? id,
    String? eventId,
    String? productId,
    double? price,
    DateTime? createdAt,
  }) {
    return EventProductModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      productId: productId ?? this.productId,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [...super.props, createdAt];
}
