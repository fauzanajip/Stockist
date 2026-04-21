import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/product_usecases.dart' as product_usecase;
import '../../../domain/usecases/event_product_usecases.dart'
    as event_product_usecase;
import 'event_product_event.dart';
import 'event_product_state.dart';

class EventProductBloc extends Bloc<EventProductEvent, EventProductState> {
  final product_usecase.GetActiveProducts getActiveProducts;
  final event_product_usecase.GetProductsByEvent getProductsByEvent;
  final event_product_usecase.AssignProductToEvent assignProductToEvent;
  final event_product_usecase.RemoveProductFromEvent removeProductFromEvent;
  final event_product_usecase.UpdateEventProductPrice updateEventProductPrice;

  EventProductBloc({
    required this.getActiveProducts,
    required this.getProductsByEvent,
    required this.assignProductToEvent,
    required this.removeProductFromEvent,
    required this.updateEventProductPrice,
  }) : super(EventProductInitial()) {
    on<LoadAvailableProducts>(_onLoadAvailableProducts);
    on<AssignProduct>(_onAssignProduct);
    on<UnassignProduct>(_onUnassignProduct);
    on<UpdateEventProductPrice>(_onUpdateEventProductPrice);
    on<SaveAllAssignedProducts>(_onSaveAllAssignedProducts);
  }

  Future<void> _onLoadAvailableProducts(
    LoadAvailableProducts event,
    Emitter<EventProductState> emit,
  ) async {
    try {
      emit(EventProductLoading());
      final availableProducts = await getActiveProducts();
      final assignedProducts = await getProductsByEvent(event.eventId);
      emit(
        AvailableProductsLoaded(
          products: availableProducts,
          assignedProducts: assignedProducts,
        ),
      );
    } catch (e) {
      emit(EventProductError(message: e.toString()));
    }
  }

  Future<void> _onAssignProduct(
    AssignProduct event,
    Emitter<EventProductState> emit,
  ) async {
    try {
      emit(EventProductLoading());
      await assignProductToEvent(
        event_product_usecase.AssignProductToEventParams(
          eventId: event.eventId,
          productId: event.productId,
          price: event.price,
        ),
      );
      final availableProducts = await getActiveProducts();
      final assignedProducts = await getProductsByEvent(event.eventId);
      emit(
        AvailableProductsLoaded(
          products: availableProducts,
          assignedProducts: assignedProducts,
        ),
      );
    } catch (e) {
      emit(EventProductError(message: e.toString()));
    }
  }

  Future<void> _onUnassignProduct(
    UnassignProduct event,
    Emitter<EventProductState> emit,
  ) async {
    try {
      emit(EventProductLoading());
      await removeProductFromEvent(event.eventProductId);
      emit(ProductUnassigned());
    } catch (e) {
      emit(EventProductError(message: e.toString()));
    }
  }

  Future<void> _onUpdateEventProductPrice(
    UpdateEventProductPrice event,
    Emitter<EventProductState> emit,
  ) async {
    try {
      await updateEventProductPrice(
        eventProductId: event.eventProductId,
        price: event.price,
      );
    } catch (e) {
      emit(EventProductError(message: e.toString()));
    }
  }

  Future<void> _onSaveAllAssignedProducts(
    SaveAllAssignedProducts event,
    Emitter<EventProductState> emit,
  ) async {
    try {
      emit(EventProductLoading());
      for (final product in event.assignedProducts) {
        await assignProductToEvent(
          event_product_usecase.AssignProductToEventParams(
            eventId: event.eventId,
            productId: product.productId,
            price: product.price,
          ),
        );
      }
      emit(AllProductsSaved());
    } catch (e) {
      emit(EventProductError(message: e.toString()));
    }
  }
}
