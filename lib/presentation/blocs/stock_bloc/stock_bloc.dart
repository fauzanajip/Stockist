import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/stock_mutation_usecases.dart';
import 'stock_bloc.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final CreateStockMutation createStockMutation;
  final GetTotalGiven getTotalGiven;
  final GetTotalReturn getTotalReturn;

  StockBloc({
    required this.createStockMutation,
    required this.getTotalGiven,
    required this.getTotalReturn,
  }) : super(const StockState()) {
    on<CreateInitialDistribution>(_onCreateInitialDistribution);
    on<CreateTopup>(_onCreateTopup);
    on<CreateReturn>(_onCreateReturn);
    on<LoadStockByEventSpg>(_onLoadStockByEventSpg);
  }

  Future<void> _onCreateInitialDistribution(
    CreateInitialDistribution event,
    Emitter<StockState> emit,
  ) async {
    try {
      await createStockMutation(
        CreateStockMutationParams(
          eventId: event.eventId,
          spgId: event.spgId,
          productId: event.productId,
          qty: event.qty,
          type: MutationType.initial,
        ),
      );
      add(LoadStockByEventSpg(eventId: event.eventId, spgId: event.spgId));
    } catch (e) {
      // TODO: Emit error state
    }
  }

  Future<void> _onCreateTopup(
    CreateTopup event,
    Emitter<StockState> emit,
  ) async {
    try {
      await createStockMutation(
        CreateStockMutationParams(
          eventId: event.eventId,
          spgId: event.spgId,
          productId: event.productId,
          qty: event.qty,
          type: MutationType.topup,
          note: event.note,
        ),
      );
      add(LoadStockByEventSpg(eventId: event.eventId, spgId: event.spgId));
    } catch (e) {
      // TODO: Emit error state
    }
  }

  Future<void> _onCreateReturn(
    CreateReturn event,
    Emitter<StockState> emit,
  ) async {
    try {
      await createStockMutation(
        CreateStockMutationParams(
          eventId: event.eventId,
          spgId: event.spgId,
          productId: event.productId,
          qty: event.qty,
          type: MutationType.returnMutation,
          note: event.note,
        ),
      );
      add(LoadStockByEventSpg(eventId: event.eventId, spgId: event.spgId));
    } catch (e) {
      // TODO: Emit error state
    }
  }

  Future<void> _onLoadStockByEventSpg(
    LoadStockByEventSpg event,
    Emitter<StockState> emit,
  ) async {
    try {
      // Need to get product-specific totals
      // For now, load all mutations and calculate
      emit(state);
    } catch (e) {
      // TODO: Emit error state
    }
  }
}
