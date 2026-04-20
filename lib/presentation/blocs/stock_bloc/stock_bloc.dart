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
  }

  Future<void> _onCreateTopup(
    CreateTopup event,
    Emitter<StockState> emit,
  ) async {
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
  }

  Future<void> _onCreateReturn(
    CreateReturn event,
    Emitter<StockState> emit,
  ) async {
    await createStockMutation(
      CreateStockMutationParams(
        eventId: event.eventId,
        spgId: event.spgId,
        productId: event.productId,
        qty: event.qty,
        type: MutationType.return,
        note: event.note,
      ),
    );
    
    add(LoadStockByEventSpg(eventId: event.eventId, spgId: event.spgId));
  }

  Future<void> _onLoadStockByEventSpg(
    LoadStockByEventSpg event,
    Emitter<StockState> emit,
  ) async {
    final givenResult = await getTotalGiven(event.eventId, event.spgId, '');
    final returnResult = await getTotalReturn(event.eventId, event.spgId, '');
    
    givenResult.fold(
      (failure) => {},
      (totalGiven) {
        returnResult.fold(
          (failure) => {},
          (totalReturn) {
            emit(state.copyWith(
              totalGiven: totalGiven,
              totalReturn: totalReturn,
            ));
          },
        );
      },
    );
  }
}
