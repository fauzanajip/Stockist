import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<ProductEntity> products;

  const ProductsLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class ProductCreated extends ProductState {
  final ProductEntity product;

  const ProductCreated({required this.product});

  @override
  List<Object?> get props => [product];
}

class ProductUpdated extends ProductState {
  final ProductEntity product;

  const ProductUpdated({required this.product});

  @override
  List<Object?> get props => [product];
}

class ProductDeleted extends ProductState {}

class ProductError extends ProductState {
  final String message;

  const ProductError({required this.message});

  @override
  List<Object?> get props => [message];
}
