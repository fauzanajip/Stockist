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
    on<SyncEventProducts>(_onSyncEventProducts);
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

  Future<void> _onSyncEventProducts(
    SyncEventProducts event,
    Emitter<EventProductState> emit,
  ) async {
    try {
      emit(EventProductLoading());

      // 1. Get current state from DB
      final currentInDb = await getProductsByEvent(event.eventId);

      // 2. Identify products to remove
      final draftProductIds = event.assignedProducts
          .map((p) => p.productId)
          .toSet();
      final toRemove = currentInDb.where(
        (p) => !draftProductIds.contains(p.productId),
      );

      for (final p in toRemove) {
        await removeProductFromEvent(p.id);
      }

      // 3. Add or Update products from draft
      for (final draft in event.assignedProducts) {
        final existing = currentInDb.where(
          (p) => p.productId == draft.productId,
        );

        if (existing.isEmpty) {
          // Add new
          await assignProductToEvent(
            event_product_usecase.AssignProductToEventParams(
              eventId: event.eventId,
              productId: draft.productId,
              price: draft.price,
            ),
          );
        } else {
          // Update existing if price changed
          if (existing.first.price != draft.price) {
            await updateEventProductPrice(
              eventProductId: existing.first.id,
              price: draft.price,
            );
          }
        }
      }

      // 4. Reload final state
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
}
