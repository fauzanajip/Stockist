import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<LoadAllProducts>(_onLoadAllProducts);
    on<LoadActiveProducts>(_onLoadActiveProducts);
  }

  Future<void> _onLoadAllProducts(
    LoadAllProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    // TODO: Implement with repository
  }

  Future<void> _onLoadActiveProducts(
    LoadActiveProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    // TODO: Implement with repository
  }
}
