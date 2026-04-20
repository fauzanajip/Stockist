import 'package:equatable/equatable.dart';
import '../../../domain/entities/product_entity.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllProducts extends ProductEvent {}

class LoadActiveProducts extends ProductEvent {}

class CreateNewProduct extends ProductEvent {
  final String name;
  final String sku;
  final double price;

  const CreateNewProduct({
    required this.name,
    required this.sku,
    required this.price,
  });

  @override
  List<Object?> get props => [name, sku, price];
}

class UpdateProduct extends ProductEvent {
  final ProductEntity product;

  const UpdateProduct({required this.product});

  @override
  List<Object?> get props => [product];
}

class DeleteProduct extends ProductEvent {
  final String id;

  const DeleteProduct({required this.id});

  @override
  List<Object?> get props => [id];
}

class SoftDeleteProduct extends ProductEvent {
  final String id;

  const SoftDeleteProduct({required this.id});

  @override
  List<Object?> get props => [id];
}
