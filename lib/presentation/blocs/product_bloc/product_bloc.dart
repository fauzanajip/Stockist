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
    on<CreateMultipleProducts>(_onCreateMultipleProducts);
    on<UpdateProduct>(_onUpdateProduct);
    on<SoftDeleteProductEvent>(_onSoftDeleteProduct);
  }

  Future<void> _onCreateMultipleProducts(
    CreateMultipleProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(ProductLoading());
      int successCount = 0;
      List<String> errors = [];
      
      for (var p in event.products) {
        try {
          await createProduct(
            usecase.CreateProductParams(name: p.name, sku: p.sku, price: p.price),
          );
          successCount++;
        } catch (e) {
          errors.add('${p.name}: ${e.toString().replaceAll('Exception: ', '')}');
        }
      }

      if (errors.isNotEmpty) {
        emit(ProductError(message: 'Sukses $successCount, Gagal ${errors.length}:\n${errors.take(2).join('\n')}${errors.length > 2 ? '\n...' : ''}'));
      } else {
        // Here we just use a mock product for the created state since UI just checks state type
        emit(ProductCreated(product: null));
      }
      add(LoadActiveProducts());
    } catch (e) {
      emit(ProductError(message: e.toString()));
      add(LoadActiveProducts());
    }
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
      add(LoadActiveProducts());
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
