import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../domain/entities/stock_mutation_entity.dart';
import '../../blocs/stock_bloc/stock_bloc.dart';
import '../../blocs/stock_bloc/stock_event.dart';
import '../../blocs/stock_bloc/stock_state.dart';
import '../../blocs/product_bloc/product_bloc.dart';
import '../../blocs/product_bloc/product_state.dart';
import '../../blocs/spg_bloc/spg_bloc.dart';
import '../../blocs/spg_bloc/spg_state.dart';

class StockHistoryScreen extends StatefulWidget {
  final String eventId;
  final String? spgId;

  const StockHistoryScreen({super.key, required this.eventId, this.spgId});

  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen> {
  MutationType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    if (widget.spgId != null) {
      context.read<StockBloc>().add(
            LoadStockByEventSpg(eventId: widget.eventId, spgId: widget.spgId!),
          );
    } else {
      context.read<StockBloc>().add(LoadStockByEvent(eventId: widget.eventId));
    }
  }

  String _getTypeLabel(MutationType type) {
    switch (type) {
      case MutationType.initial:
        return 'INITIAL';
      case MutationType.topup:
        return 'TOPUP';
      case MutationType.returnMutation:
        return 'RECOVERY';
      case MutationType.distributorToEvent:
        return 'SUPPLY';
    }
  }

  Color _getTypeColor(MutationType type) {
    switch (type) {
      case MutationType.initial:
        return AppColors.primary;
      case MutationType.topup:
        return AppColors.success;
      case MutationType.returnMutation:
        return AppColors.warning;
      case MutationType.distributorToEvent:
        return AppColors.secondary;
    }
  }

  List<StockMutationEntity> _filterMutations(
    List<StockMutationEntity> mutations,
  ) {
    if (_selectedFilter == null) return mutations;
    return mutations.where((m) => m.type == _selectedFilter).toList();
  }

  void _showEditBottomSheet(StockMutationEntity mutation) {
    final productBloc = context.read<ProductBloc>();
    final productState = productBloc.state;

    String productName = mutation.productId;
    if (productState is ProductsLoaded) {
      final product = productState.products.firstWhereOrNull(
        (p) => p.id == mutation.productId,
      );
      if (product != null) productName = product.name;
    }

    int newQty = mutation.qty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.zero,
          ),
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ASSET_LOG_CORRECTION'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                productName.toUpperCase(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              Text(
                'TYPE: ${_getTypeLabel(mutation.type)}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              const Text(
                'CORRECT_QUANTITY_INPUT',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant, letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  border: Border.all(color: AppColors.surfaceContainerHigh),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => setModalState(() => newQty = newQty > 0 ? newQty - 1 : 0),
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                    ),
                    Text(
                      newQty.toString(),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                    IconButton(
                      onPressed: () => setModalState(() => newQty++),
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.success),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('ABORT_CORRECTION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _updateMutation(mutation, newQty);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text('COMMIT_CHANGES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateMutation(StockMutationEntity mutation, int newQty) {
    context.read<StockBloc>().add(
          UpdateStockMutation(
            mutationId: mutation.id,
            eventId: mutation.eventId,
            spgId: mutation.spgId,
            productId: mutation.productId,
            newQty: newQty,
          ),
        );
  }

  void _showDeleteConfirmBottomSheet(StockMutationEntity mutation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.zero,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: 24),
            Text(
              'DELETE_LOG_ENTRY'.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'THIS ACTION IS IRREVERSIBLE. DELETING THIS ENTRY WILL RECALCULATE MISSION INVENTORY LEVELS.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('ABORT', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteMutation(mutation);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: const Text('CONFIRM_DELETE', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMutation(StockMutationEntity mutation) {
    context.read<StockBloc>().add(
          DeleteStockMutation(
            mutationId: mutation.id,
            eventId: mutation.eventId,
            spgId: mutation.spgId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StockBloc, StockState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceContainerLowest,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LOGISTICS_AUDIT'.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
              ),
              Text(
                widget.spgId != null ? 'UNIT_ASSET_LOGS' : 'MISSION_SUPPLY_CHAIN',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _loadData,
              icon: const Icon(Icons.sync_rounded, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: AppColors.surfaceContainerHigh, height: 1),
          ),
        ),
        body: Column(
          children: [
            _buildFilterChips(),
            Expanded(child: _buildMutationList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _buildTacticalChip(null, 'ALL_ENTRIES'),
            const SizedBox(width: 8),
            _buildTacticalChip(MutationType.initial, 'INITIAL'),
            const SizedBox(width: 8),
            _buildTacticalChip(MutationType.topup, 'TOPUP'),
            const SizedBox(width: 8),
            _buildTacticalChip(MutationType.returnMutation, 'RECOVERY'),
            const SizedBox(width: 8),
            _buildTacticalChip(MutationType.distributorToEvent, 'SUPPLY'),
          ],
        ),
      ),
    );
  }

  Widget _buildTacticalChip(MutationType? type, String label) {
    final isSelected = _selectedFilter == type;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = isSelected ? null : type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildMutationList() {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
        if (stockState.isLoading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        final mutations = _filterMutations(stockState.mutations);
        if (mutations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_toggle_off_rounded, size: 48, color: AppColors.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  'NO_LOGS_FOUND'.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, productState) {
            return BlocBuilder<SpgBloc, SpgState>(
              builder: (context, spgState) {
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: mutations.length,
                  itemBuilder: (context, index) {
                    final mutation = mutations[index];
                    return _buildMutationCard(mutation, productState, spgState);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMutationCard(
    StockMutationEntity mutation,
    ProductState productState,
    SpgState spgState,
  ) {
    String productName = mutation.productId;
    if (productState is ProductsLoaded) {
      final product = productState.products.firstWhereOrNull(
        (p) => p.id == mutation.productId,
      );
      if (product != null) productName = product.name;
    }

    String spgName = mutation.spgId;
    if (spgState is SpqsLoaded && mutation.spgId != 'WAREHOUSE') {
      final spg = spgState.spqs.firstWhereOrNull((s) => s.id == mutation.spgId);
      if (spg != null) spgName = spg.name;
    } else if (mutation.spgId == 'WAREHOUSE') {
      spgName = 'CENTRAL_WAREHOUSE';
    }

    final typeColor = _getTypeColor(mutation.type);
    final typeLabel = _getTypeLabel(mutation.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: InkWell(
        onTap: () => _showEditBottomSheet(mutation),
        onLongPress: () => _showDeleteConfirmBottomSheet(mutation),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  border: Border.all(color: typeColor.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    mutation.qty.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: typeColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          color: typeColor.withOpacity(0.1),
                          child: Text(
                            typeLabel,
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: typeColor, letterSpacing: 0.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          spgName.toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(mutation.timestamp),
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showEditBottomSheet(mutation),
                    icon: const Icon(Icons.edit_note_rounded, size: 20),
                    color: AppColors.onSurfaceVariant,
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: () => _showDeleteConfirmBottomSheet(mutation),
                    icon: const Icon(Icons.delete_forever_rounded, size: 20),
                    color: AppColors.error.withOpacity(0.7),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute'.toUpperCase();
  }
}
