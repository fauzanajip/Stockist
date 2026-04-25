import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/sales_usecases.dart';
import 'sales_event.dart';
import 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final CreateOrUpdateSales createOrUpdateSales;
  final GetSalesByEventSpg getSalesByEventSpg;
  final GetSalesByEvent getSalesByEvent;
  final BulkReplaceSales bulkReplaceSales;

  SalesBloc({
    required this.createOrUpdateSales,
    required this.getSalesByEventSpg,
    required this.getSalesByEvent,
    required this.bulkReplaceSales,
  }) : super(const SalesState()) {
    on<UpdateSales>(_onUpdateSales);
    on<LoadSales>(_onLoadSales);
    on<LoadAllSalesByEvent>(_onLoadAllSalesByEvent);
    on<BulkReplaceSalesEvent>(_onBulkReplaceSales);
  }

  Future<void> _onUpdateSales(
    UpdateSales event,
    Emitter<SalesState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await createOrUpdateSales(
        CreateOrUpdateSalesParams(
          eventId: event.eventId,
          spgId: event.spgId,
          productId: event.productId,
          qtySold: event.qtySold,
        ),
      );
      add(LoadAllSalesByEvent(eventId: event.eventId));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadSales(LoadSales event, Emitter<SalesState> emit) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final salesList = await getSalesByEventSpg(event.eventId, event.spgId);
      final salesMap = <String, int>{};
      for (final sales in salesList) {
        salesMap[sales.productId] = sales.qtySold;
      }
      emit(state.copyWith(isLoading: false, salesByProduct: salesMap));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadAllSalesByEvent(
    LoadAllSalesByEvent event,
    Emitter<SalesState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final allSales = await getSalesByEvent(event.eventId);
      emit(state.copyWith(isLoading: false, allSales: allSales));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onBulkReplaceSales(
    BulkReplaceSalesEvent event,
    Emitter<SalesState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await bulkReplaceSales(
        BulkReplaceSalesParams(
          eventId: event.eventId,
          salesItems: event.salesItems,
        ),
      );
      final allSales = await getSalesByEvent(event.eventId);
      emit(state.copyWith(isLoading: false, allSales: allSales));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
