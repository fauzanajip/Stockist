import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/sales_usecases.dart';
import 'sales_bloc.dart';

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
    await createOrUpdateSales(
      CreateOrUpdateSalesParams(
        eventId: event.eventId,
        spgId: event.spgId,
        productId: event.productId,
        qtySold: event.qtySold,
      ),
    );
    
    add(LoadSales(eventId: event.eventId, spgId: event.spgId));
  }

  Future<void> _onLoadSales(
    LoadSales event,
    Emitter<SalesState> emit,
  ) async {
    final result = await getSalesByEventSpg(event.eventId, event.spgId);
    
    result.fold(
      (failure) => {},
      (salesList) {
        final salesMap = <String, int>{};
        for (final sales in salesList) {
          salesMap[sales.productId] = sales.qtySold;
        }
        emit(state.copyWith(salesByProduct: salesMap));
      },
    );
  }
}
