import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/stock_mutation_entity.dart';
import '../../../domain/entities/pending_topup_entity.dart';
import '../../../domain/usecases/stock_mutation_usecases.dart';
import '../../../domain/usecases/sales_usecases.dart';
import '../../../domain/usecases/pending_topup_usecases.dart';
import '../../../domain/repositories/event_spg_repository.dart';
import '../../../domain/repositories/pending_topup_repository.dart';
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
  final CreatePendingTopupUsecase createPendingTopup;
  final PendingTopupRepository pendingTopupRepository;
  final EventSpgRepository eventSpgRepository;

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
    required this.createPendingTopup,
    required this.pendingTopupRepository,
    required this.eventSpgRepository,
  }) : super(const StockState()) {
    on<CreateInitialDistribution>(_onCreateInitialDistribution);
    on<BulkCreateOrUpdateInitialDistributionEvent>(_onBulkCreateOrUpdateInitialDistribution);
    on<CreateTopup>(_onCreateTopup);
    on<BulkCreateTopupEvent>(_onBulkCreateTopup);
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
      final mutation = await createStockMutation(
        CreateStockMutationParams(
          eventId: event.eventId,
          spgId: event.spgId,
          productId: event.productId,
          qty: event.qty,
          type: MutationType.initial,
        ),
      );
      final spbId = await eventSpgRepository.getSpbIdBySpg(event.eventId, event.spgId);
      await createPendingTopup(
        PendingTopupEntity(
          id: '',
          eventId: event.eventId,
          spbId: spbId,
          spgId: event.spgId,
          productId: event.productId,
          qty: event.qty,
          type: PendingTopupType.initial,
          isChecked: true,
          stockMutationId: mutation.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
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
      for (final dist in event.distributions) {
        if (dist.qty > 0) {
          final spbId = await eventSpgRepository.getSpbIdBySpg(dist.eventId, dist.spgId);
          final mutations = await getStockMutationsByEvent(dist.eventId);
          final mutation = mutations.firstWhere(
            (m) => m.spgId == dist.spgId && m.productId == dist.productId && m.type == MutationType.initial,
            orElse: () => throw Exception('Mutation not found'),
          );
          await createPendingTopup(
            PendingTopupEntity(
              id: '',
              eventId: dist.eventId,
              spbId: spbId,
              spgId: dist.spgId,
              productId: dist.productId,
              qty: dist.qty,
              type: PendingTopupType.initial,
              isChecked: true,
              stockMutationId: mutation.id,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        }
      }
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
      final mutation = await createStockMutation(
        CreateStockMutationParams(
          eventId: event.eventId,
          spgId: event.spgId,
          productId: event.productId,
          qty: event.qty,
          type: MutationType.topup,
          note: event.note,
        ),
      );
      final spbId = await eventSpgRepository.getSpbIdBySpg(event.eventId, event.spgId);
      await createPendingTopup(
        PendingTopupEntity(
          id: '',
          eventId: event.eventId,
          spbId: spbId,
          spgId: event.spgId,
          productId: event.productId,
          qty: event.qty,
          type: PendingTopupType.topup,
          isChecked: true,
          stockMutationId: mutation.id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      add(LoadStockByEvent(eventId: event.eventId));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onBulkCreateTopup(
    BulkCreateTopupEvent event,
    Emitter<StockState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      for (final topup in event.topups) {
        if (topup.qty > 0) {
          final mutation = await createStockMutation(
            CreateStockMutationParams(
              eventId: topup.eventId,
              spgId: topup.spgId,
              productId: topup.productId,
              qty: topup.qty,
              type: MutationType.topup,
              note: null,
            ),
          );
          final spbId = await eventSpgRepository.getSpbIdBySpg(topup.eventId, topup.spgId);
          await createPendingTopup(
            PendingTopupEntity(
              id: '',
              eventId: topup.eventId,
              spbId: spbId,
              spgId: topup.spgId,
              productId: topup.productId,
              qty: topup.qty,
              type: PendingTopupType.topup,
              isChecked: true,
              stockMutationId: mutation.id,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
        }
      }
      if (event.topups.isNotEmpty) {
        add(LoadStockByEvent(eventId: event.topups.first.eventId));
      }
      emit(state.copyWith(isLoading: false));
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
