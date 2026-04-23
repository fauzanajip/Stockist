import 'package:equatable/equatable.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/event_product_entity.dart';

abstract class EventProductState extends Equatable {
  const EventProductState();

  @override
  List<Object?> get props => [];
}

class EventProductInitial extends EventProductState {}

class EventProductLoading extends EventProductState {}

class AvailableProductsLoaded extends EventProductState {
  final List<ProductEntity> products;
  final List<EventProductEntity> assignedProducts;

  const AvailableProductsLoaded({
    required this.products,
    required this.assignedProducts,
  });

  @override
  List<Object?> get props => [products, assignedProducts];
}

class AssignedProductsLoaded extends EventProductState {
  final List<EventProductEntity> products;

  const AssignedProductsLoaded({required this.products});

  @override
  List<Object?> get props => [products];
}

class ProductAssigned extends EventProductState {
  final EventProductEntity product;

  const ProductAssigned({required this.product});

  @override
  List<Object?> get props => [product];
}

class ProductUnassigned extends EventProductState {}

class AllProductsSaved extends EventProductState {}

class EventProductError extends EventProductState {
  final String message;

  const EventProductError({required this.message});

  @override
  List<Object?> get props => [message];
}
