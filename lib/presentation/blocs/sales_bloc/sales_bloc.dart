import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/sales_usecases.dart';
import 'sales_event.dart';
import 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final CreateOrUpdateSales createOrUpdateSales;
  final GetSalesByEventSpg getSalesByEventSpg;

  SalesBloc({
    required this.createOrUpdateSales,
    required this.getSalesByEventSpg,
  }) : super(const SalesState()) {
    on<UpdateSales>(_onUpdateSales);
    on<LoadSales>(_onLoadSales);
  }

  Future<void> _onUpdateSales(
    UpdateSales event,
    Emitter<SalesState> emit,
  ) async {
    try {
      await createOrUpdateSales(
        CreateOrUpdateSalesParams(
          eventId: event.eventId,
          spgId: event.spgId,
          productId: event.productId,
          qtySold: event.qtySold,
        ),
      );
      add(LoadSales(eventId: event.eventId, spgId: event.spgId));
    } catch (e) {
      // TODO: Emit error state
    }
  }

  Future<void> _onLoadSales(
    LoadSales event,
    Emitter<SalesState> emit,
  ) async {
    try {
      final salesList = await getSalesByEventSpg(event.eventId, event.spgId);
      final salesMap = <String, int>{};
      for (final sales in salesList) {
        salesMap[sales.productId] = sales.qtySold;
      }
      emit(state.copyWith(salesByProduct: salesMap));
    } catch (e) {
      // TODO: Emit error state
    }
  }
}
