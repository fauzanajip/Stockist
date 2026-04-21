import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/product_usecases.dart' as usecase;
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final usecase.GetAllProducts getAllProducts;
  final usecase.GetActiveProducts getActiveProducts;
  final usecase.CreateProduct createProduct;
  final usecase.UpdateProduct updateProduct;
  final usecase.SoftDeleteProduct softDeleteProduct;

  ProductBloc({
    required this.getAllProducts,
    required this.getActiveProducts,
    required this.createProduct,
    required this.updateProduct,
    required this.softDeleteProduct,
  }) : super(ProductInitial()) {
    on<LoadAllProducts>(_onLoadAllProducts);
    on<LoadActiveProducts>(_onLoadActiveProducts);
    on<CreateNewProduct>(_onCreateNewProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<SoftDeleteProductEvent>(_onSoftDeleteProduct);
  }

  Future<void> _onLoadAllProducts(
    LoadAllProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      final products = await getAllProducts();
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> _onLoadActiveProducts(
    LoadActiveProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      final products = await getActiveProducts();
      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> _onCreateNewProduct(
    CreateNewProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      final product = await createProduct(
        usecase.CreateProductParams(
          name: event.name,
          sku: event.sku,
          price: event.price,
        ),
      );
      emit(ProductCreated(product: product));
      add(LoadActiveProducts());
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      final product = await updateProduct(event.product);
      emit(ProductUpdated(product: product));
      add(LoadActiveProducts());
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> _onSoftDeleteProduct(
    SoftDeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      await softDeleteProduct(event.id);
      emit(ProductDeleted());
      add(LoadActiveProducts());
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }
}