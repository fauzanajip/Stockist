import '../../domain/entities/product_entity.dart';
import '../data_sources/database_helper.dart';

class ProductModel extends ProductEntity {
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required super.id,
    required super.name,
    required super.sku,
    required super.price,
    super.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      sku: entity.sku,
      price: entity.price,
      deletedAt: entity.deletedAt,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      sku: map['sku'] as String,
      price: (map['price'] as num).toDouble(),
      deletedAt: map['deleted_at'] != null 
          ? DatabaseHelper.stringToDateTime(map['deleted_at'] as String) 
          : null,
      createdAt: DatabaseHelper.stringToDateTime(map['created_at'] as String),
      updatedAt: DatabaseHelper.stringToDateTime(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'price': price,
      'deleted_at': deletedAt != null ? DatabaseHelper.dateTimeToString(deletedAt!) : null,
      'created_at': DatabaseHelper.dateTimeToString(createdAt),
      'updated_at': DatabaseHelper.dateTimeToString(updatedAt),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? sku,
    double? price,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [...super.props, createdAt, updatedAt];
}
