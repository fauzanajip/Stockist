import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String sku;
  final double price;
  final DateTime? deletedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  ProductEntity copyWith({
    String? id,
    String? name,
    String? sku,
    double? price,
    DateTime? deletedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, sku, price, deletedAt];
}
