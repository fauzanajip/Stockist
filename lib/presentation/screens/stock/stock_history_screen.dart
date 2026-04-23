import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
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
        return 'Initial';
      case MutationType.topup:
        return 'Topup';
      case MutationType.returnMutation:
        return 'Return';
      case MutationType.distributorToEvent:
        return 'Distributor';
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

  void _showEditDialog(StockMutationEntity mutation) {
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Qty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: $productName'),
            Text('Type: ${_getTypeLabel(mutation.type)}'),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () =>
                        setState(() => newQty = newQty > 0 ? newQty - 1 : 0),
                    icon: const Icon(Icons.remove_circle_outline),
                    color: AppColors.error,
                  ),
                  Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      newQty.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => newQty++),
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.success,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateMutation(mutation, newQty);
            },
            child: const Text('Save'),
          ),
        ],
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

  void _showDeleteConfirmDialog(StockMutationEntity mutation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Distribusi?'),
        content: const Text('Data yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              _deleteMutation(mutation);
            },
            child: const Text('Hapus'),
          ),
        ],
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
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.spgId != null ? 'Riwayat SPG' : 'Riwayat Distribusi',
          ),
          actions: [
            IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
          ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(null, 'All'),
            const SizedBox(width: 8),
            _buildFilterChip(MutationType.initial, 'Initial'),
            const SizedBox(width: 8),
            _buildFilterChip(MutationType.topup, 'Topup'),
            const SizedBox(width: 8),
            _buildFilterChip(MutationType.returnMutation, 'Return'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(MutationType? type, String label) {
    final isSelected = _selectedFilter == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = selected ? type : null);
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildMutationList() {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
        if (stockState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final mutations = _filterMutations(stockState.mutations);
        if (mutations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.history,
                  size: 64,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                const Text('Tidak ada data distribusi'),
              ],
            ),
          );
        }

        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, productState) {
            return BlocBuilder<SpgBloc, SpgState>(
              builder: (context, spgState) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
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
      spgName = 'Warehouse';
    }

    final typeColor = _getTypeColor(mutation.type);
    final typeLabel = _getTypeLabel(mutation.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showEditDialog(mutation),
        onLongPress: () => _showDeleteConfirmDialog(mutation),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    mutation.qty.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                      productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          spgName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(mutation.timestamp),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showEditDialog(mutation),
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: AppColors.onSurfaceVariant,
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmDialog(mutation),
                icon: const Icon(Icons.delete_outline, size: 20),
                color: AppColors.error,
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
    return '$day/$month $hour:$minute';
  }
}
