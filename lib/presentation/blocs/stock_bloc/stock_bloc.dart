import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/stock_mutation_entity.dart';
import '../../../domain/usecases/stock_mutation_usecases.dart';
import '../../../domain/usecases/sales_usecases.dart';
import 'stock_event.dart';
import 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final CreateStockMutation createStockMutation;
  final GetTotalGiven getTotalGiven;
  final GetTotalReturn getTotalReturn;
  final GetStockMutationsByEventSpg getStockMutationsByEventSpg;
  final GetStockMutationsByEvent getStockMutationsByEvent;
  final UpdateStockMutationQty updateStockMutationQty;
  final DeleteStockMutationRecord deleteStockMutationRecord;
  final GetTotalSold getTotalSold;
  final BulkCreateOrUpdateInitialStock bulkCreateOrUpdateInitialStock;
  final GetWarehouseStockByProduct getWarehouseStockByProduct;
  final GetDistributedByProduct getDistributedByProduct;
  final GetReturnsByProduct getReturnsByProduct;

  StockBloc({
    required this.createStockMutation,
    required this.getTotalGiven,
    required this.getTotalReturn,
    required this.getStockMutationsByEventSpg,
    required this.getStockMutationsByEvent,
    required this.updateStockMutationQty,
    required this.deleteStockMutationRecord,
    required this.getTotalSold,
    required this.bulkCreateOrUpdateInitialStock,
    required this.getWarehouseStockByProduct,
    required this.getDistributedByProduct,
    required this.getReturnsByProduct,
  }) : super(const StockState()) {
    on<CreateInitialDistribution>(_onCreateInitialDistribution);
    on<BulkCreateOrUpdateInitialDistributionEvent>(_onBulkCreateOrUpdateInitialDistribution);
    on<CreateTopup>(_onCreateTopup);
    on<CreateReturn>(_onCreateReturn);
    on<LoadStockByEventSpg>(_onLoadStockByEventSpg);
    on<LoadStockByEvent>(_onLoadStockByEvent);
    on<CreateDistributorStock>(_onCreateDistributorStock);
    on<UpdateStockMutation>(_onUpdateStockMutation);
    on<DeleteStockMutation>(_onDeleteStockMutation);
  }

  Future<void> _onCreateDistributorStock(
    CreateDistributorStock event,
    Emitter<StockState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await createStockMutation(
        CreateStockMutationParams(
          eventId: event.eventId,
          spgId: 'WAREHOUSE', // Special ID for global event stock
          productId: event.productId,
          qty: event.qty,
          type: MutationType.distributorToEvent,
        ),
      );
      add(LoadStockByEvent(eventId: event.eventId));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadStockByEvent(
    LoadStockByEvent event,
    Emitter<StockState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final mutations = await getStockMutationsByEvent(event.eventId);
      emit(state.copyWith(isLoading: false, mutations: mutations));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateInitialDistribution(
    CreateInitialDistribution event,
    Emitter<StockState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await createStockMutation(
        CreateStockMutationParams(
          eventId: event.eventId,
          spgId: event.spgId,
          productId: event.productId,
          qty: event.qty,
          type: MutationType.initial,
        ),
      );
      add(LoadStockByEvent(eventId: event.eventId));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onBulkCreateOrUpdateInitialDistribution(
    BulkCreateOrUpdateInitialDistributionEvent event,
    Emitter<StockState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await bulkCreateOrUpdateInitialStock(event.distributions);
      if (event.distributions.isNotEmpty) {
        add(LoadStockByEvent(eventId: event.distributions.first.eventId));
      }
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateTopup(
    CreateTopup event,
    Emitter<StockState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
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
      add(LoadStockByEvent(eventId: event.eventId));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onCreateReturn(
    CreateReturn event,
    Emitter<StockState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
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
      add(LoadStockByEvent(eventId: event.eventId));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadStockByEventSpg(
    LoadStockByEventSpg event,
    Emitter<StockState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final mutations = await getStockMutationsByEventSpg(
        event.eventId,
        event.spgId,
      );

      final initialQty = mutations
          .where((m) => m.type == MutationType.initial)
          .fold(0, (sum, m) => sum + m.qty);
      final topupQty = mutations
          .where((m) => m.type == MutationType.topup)
          .fold(0, (sum, m) => sum + m.qty);
      final returnQty = mutations
          .where((m) => m.type == MutationType.returnMutation)
          .fold(0, (sum, m) => sum + m.qty);

      emit(
        state.copyWith(
          isLoading: false,
          mutations: mutations,
          totalGiven: initialQty + topupQty,
          totalReturn: returnQty,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateStockMutation(
    UpdateStockMutation event,
    Emitter<StockState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      final mutation = state.mutations.firstWhere(
        (m) => m.id == event.mutationId,
        orElse: () => throw Exception('Mutation not found'),
      );

      if (mutation.type == MutationType.distributorToEvent) {
        await updateStockMutationQty(event.mutationId, event.newQty);
        add(LoadStockByEvent(eventId: event.eventId));
        return;
      }

      final totalSold = await getTotalSold(
        event.eventId,
        event.spgId,
        event.productId,
      );
      final totalGiven = await getTotalGiven(
        event.eventId,
        event.spgId,
        event.productId,
      );
      final totalReturn = await getTotalReturn(
        event.eventId,
        event.spgId,
        event.productId,
      );

      final otherDistributions = totalGiven - mutation.qty;
      final minAllowedQty = totalSold + totalReturn - otherDistributions;

      if (event.newQty < minAllowedQty) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage:
                'Qty tidak bisa lebih kecil dari yang sudah terjual ($minAllowedQty)',
          ),
        );
        return;
      }

      await updateStockMutationQty(event.mutationId, event.newQty);
      add(LoadStockByEvent(eventId: event.eventId));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteStockMutation(
    DeleteStockMutation event,
    Emitter<StockState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      final mutation = state.mutations.firstWhere(
        (m) => m.id == event.mutationId,
        orElse: () => throw Exception('Mutation not found'),
      );

      if (mutation.type == MutationType.distributorToEvent) {
        await deleteStockMutationRecord(event.mutationId);
        add(LoadStockByEvent(eventId: event.eventId));
        return;
      }

      final totalSold = await getTotalSold(
        event.eventId,
        event.spgId,
        mutation.productId,
      );
      final totalGiven = await getTotalGiven(
        event.eventId,
        event.spgId,
        mutation.productId,
      );
      final totalReturn = await getTotalReturn(
        event.eventId,
        event.spgId,
        mutation.productId,
      );

      final otherDistributions = totalGiven - mutation.qty;
      final remainingAfterDelete = otherDistributions - totalReturn;

      if (remainingAfterDelete < totalSold) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Tidak bisa hapus, stok sudah ada yang terjual',
          ),
        );
        return;
      }

      await deleteStockMutationRecord(event.mutationId);
      add(LoadStockByEvent(eventId: event.eventId));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
