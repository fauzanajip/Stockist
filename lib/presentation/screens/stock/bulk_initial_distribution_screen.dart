import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import '../../../core/constants/app_theme.dart';
import '../../../domain/entities/stock_mutation_entity.dart';
import '../../../domain/repositories/stock_mutation_repository.dart';
import '../../blocs/event_spg_bloc/event_spg_bloc.dart';
import '../../blocs/event_spg_bloc/event_spg_event.dart';
import '../../blocs/event_spg_bloc/event_spg_state.dart';
import '../../blocs/event_product_bloc/event_product_bloc.dart';
import '../../blocs/event_product_bloc/event_product_event.dart';
import '../../blocs/event_product_bloc/event_product_state.dart';
import '../../blocs/stock_bloc/stock_bloc.dart';
import '../../blocs/stock_bloc/stock_event.dart';
import '../../blocs/stock_bloc/stock_state.dart';

class BulkInitialDistributionScreen extends StatefulWidget {
  final String eventId;

  const BulkInitialDistributionScreen({super.key, required this.eventId});

  @override
  State<BulkInitialDistributionScreen> createState() => _BulkInitialDistributionScreenState();
}

class _BulkInitialDistributionScreenState extends State<BulkInitialDistributionScreen> {
  final Map<String, Map<String, int>> _distributions = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<EventSpgBloc>().add(LoadAvailableSpgs(eventId: widget.eventId));
    context.read<EventProductBloc>().add(LoadAvailableProducts(eventId: widget.eventId));
    context.read<StockBloc>().add(LoadStockByEvent(eventId: widget.eventId));
  }

  void _initializeFromState(List<StockMutationEntity> mutations) {
    for (final m in mutations) {
      if (m.type == MutationType.initial) {
        if (!_distributions.containsKey(m.spgId)) {
          _distributions[m.spgId] = {};
        }
        _distributions[m.spgId]![m.productId] = m.qty;
      }
    }
  }

  void _showBulkSetDialog() {
    final eventSpgState = context.read<EventSpgBloc>().state;
    final eventProductState = context.read<EventProductBloc>().state;
    final stockState = context.read<StockBloc>().state;

    if (eventSpgState is! AvailableSpgsLoaded || eventProductState is! AvailableProductsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('DATA_NOT_READY. PLEASE WAIT.')),
      );
      return;
    }

    final selectedSpgIds = <String>[];
    final qtyInputs = <String, int>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainer,
                        border: Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.settings_input_component_outlined, color: AppColors.secondary, size: 20),
                          const SizedBox(width: 12),
                          const Text(
                            'BATCH_CONFIGURATION_PROTOCOL',
                            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'SELECT_UNITS',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppColors.onSurfaceVariant),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setSheetState(() {
                                      if (selectedSpgIds.length == eventSpgState.assignedSpgs.length) {
                                        selectedSpgIds.clear();
                                      } else {
                                        selectedSpgIds.clear();
                                        selectedSpgIds.addAll(eventSpgState.assignedSpgs.map((e) => e.spgId));
                                      }
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    selectedSpgIds.length == eventSpgState.assignedSpgs.length ? 'DESELECT_ALL' : 'SELECT_ALL',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.secondary, letterSpacing: 1),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest,
                                border: Border.all(color: AppColors.surfaceContainerHigh),
                              ),
                              child: Column(
                                children: [
                                  ...eventSpgState.assignedSpgs.map((es) {
                                    final spg = eventSpgState.spgs.firstWhereOrNull((s) => s.id == es.spgId);
                                    final isSelected = selectedSpgIds.contains(es.spgId);
                                    return CheckboxListTile(
                                      title: Text(
                                        (spg?.name ?? es.spgId).toUpperCase(),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      value: isSelected,
                                      activeColor: AppColors.secondary,
                                      checkboxShape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                      onChanged: (val) {
                                        setSheetState(() {
                                          if (val == true) {
                                            selectedSpgIds.add(es.spgId);
                                          } else {
                                            selectedSpgIds.remove(es.spgId);
                                          }
                                        });
                                      },
                                      controlAffinity: ListTileControlAffinity.leading,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                      dense: true,
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              'SET_QUANTITY_PER_ASSET',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 12),
                            ...eventProductState.assignedProducts.map((ep) {
                              final product = eventProductState.products.firstWhereOrNull((p) => p.id == ep.productId);
                              final productName = product?.name ?? ep.productId;

                              final warehouseStock = _calculateWarehouseAvailable(stockState, ep.productId, '');
                              final distributed = _getTotalDistributed(stockState, ep.productId);
                              final warehouseAvailable = warehouseStock - distributed;

                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: const BoxDecoration(
                                  color: AppColors.surfaceContainerLowest,
                                  border: Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        productName.toUpperCase(),
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextFormField(
                                        initialValue: qtyInputs[ep.productId]?.toString() ?? '0',
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                          filled: true,
                                          fillColor: AppColors.surface,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.surfaceContainerHigh)),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.secondary, width: 2)),
                                        ),
                                        onChanged: (val) {
                                          qtyInputs[ep.productId] = int.tryParse(val) ?? 0;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 60,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'WH:$warehouseAvailable',
                                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(bottomSheetContext),
                              style: OutlinedButton.styleFrom(
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                side: const BorderSide(color: AppColors.surfaceContainerHigh),
                              ),
                              child: const Text('CANCEL'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: selectedSpgIds.isEmpty ? null : () {
                                _applyBulkDistribution(selectedSpgIds, qtyInputs);
                                Navigator.pop(bottomSheetContext);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                elevation: 0,
                              ),
                              child: Text('APPLY TO ${selectedSpgIds.length} UNITS'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _applyBulkDistribution(List<String> spgIds, Map<String, int> productQtys) {
    setState(() {
      for (final spgId in spgIds) {
        if (!_distributions.containsKey(spgId)) {
          _distributions[spgId] = {};
        }
        for (final entry in productQtys.entries) {
          _distributions[spgId]![entry.key] = entry.value;
        }
      }
    });
  }

  int _calculateWarehouseAvailable(StockState stockState, String productId, String excludeSpgId) {
    final warehouseStock = stockState.mutations
        .where((m) => m.productId == productId && m.type == MutationType.distributorToEvent)
        .fold(0, (sum, m) => sum + m.qty);

    final distributedToOthers = stockState.mutations
        .where((m) => m.productId == productId && m.spgId != excludeSpgId && m.spgId != 'WAREHOUSE' && (m.type == MutationType.initial || m.type == MutationType.topup))
        .fold(0, (sum, m) => sum + m.qty);

    final returns = stockState.mutations
        .where((m) => m.productId == productId && m.type == MutationType.returnMutation)
        .fold(0, (sum, m) => sum + m.qty);

    final currentSpgInitial = excludeSpgId.isEmpty
        ? 0
        : stockState.mutations
            .where((m) => m.productId == productId && m.spgId == excludeSpgId && m.type == MutationType.initial)
            .fold(0, (sum, m) => sum + m.qty);

    return warehouseStock - distributedToOthers + returns + currentSpgInitial;
  }

  int _getTotalDistributed(StockState stockState, String productId) {
    return stockState.mutations
        .where((m) => m.productId == productId && m.spgId != 'WAREHOUSE' && (m.type == MutationType.initial || m.type == MutationType.topup))
        .fold(0, (sum, m) => sum + m.qty);
  }

  int _getCurrentInitial(StockState stockState, String spgId, String productId) {
    return stockState.mutations
        .where((m) => m.spgId == spgId && m.productId == productId && m.type == MutationType.initial)
        .fold(0, (sum, m) => sum + m.qty);
  }

  bool _hasExceededWarehouse(StockState stockState, String spgId, String productId, int newQty) {
    final available = _calculateWarehouseAvailable(stockState, productId, spgId);
    return newQty > available;
  }

  bool _hasAnyExceeded(StockState stockState) {
    for (final spgId in _distributions.keys) {
      for (final productId in _distributions[spgId]!.keys) {
        final qty = _distributions[spgId]![productId] ?? 0;
        if (_hasExceededWarehouse(stockState, spgId, productId, qty)) {
          return true;
        }
      }
    }
    return false;
  }

  void _saveDistributions() {
    final eventSpgState = context.read<EventSpgBloc>().state;
    final eventProductState = context.read<EventProductBloc>().state;

    if (eventSpgState is! AvailableSpgsLoaded || eventProductState is! AvailableProductsLoaded) {
      return;
    }

    setState(() => _isSaving = true);

    final paramsToSave = <BulkInitialParams>[];
    for (final spgId in _distributions.keys) {
      for (final productId in _distributions[spgId]!.keys) {
        paramsToSave.add(
          BulkInitialParams(
            eventId: widget.eventId,
            spgId: spgId,
            productId: productId,
            qty: _distributions[spgId]![productId] ?? 0,
          ),
        );
      }
    }

    context.read<StockBloc>().add(
      BulkCreateOrUpdateInitialDistributionEvent(distributions: paramsToSave),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LOGISTICS_COMMAND',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
            ),
            const Text(
              'INITIAL DISTRIBUTION',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: -0.5),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.surfaceContainerHigh, height: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, size: 20),
            onPressed: _loadData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<StockBloc, StockState>(
        listener: (context, state) {
          if (!state.isLoading && _isSaving) {
            setState(() => _isSaving = false);
            if (state.errorMessage == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('DISTRIBUTION_DATA_ARCHIVED: SUCCESS'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('TELEMETRY_ERROR: ${state.errorMessage!.toUpperCase()}')),
              );
            }
          }
          if (state.mutations.isNotEmpty && _distributions.isEmpty) {
            _initializeFromState(state.mutations);
          }
        },
        builder: (context, stockState) {
          return BlocBuilder<EventSpgBloc, EventSpgState>(
            builder: (context, spgState) {
              return BlocBuilder<EventProductBloc, EventProductState>(
                builder: (context, productState) {
                  if (spgState is EventSpgLoading || productState is EventProductLoading || stockState.isLoading) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  }

                  if (spgState is! AvailableSpgsLoaded || productState is! AvailableProductsLoaded) {
                    return _buildEmptyState();
                  }

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildToolbar(context)),
                      if (spgState.assignedSpgs.isEmpty)
                        SliverFillRemaining(child: _buildEmptyState())
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final es = spgState.assignedSpgs[index];
                                final spg = spgState.spgs.firstWhereOrNull((s) => s.id == es.spgId);
                                final spb = spgState.spbs.firstWhereOrNull((s) => s.id == es.spbId);

                                return _buildSpgCard(context, es, spg, spb, productState, stockState);
                              },
                              childCount: spgState.assignedSpgs.length,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal_outlined, size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'LOGISTICS_COMMAND_CENTER',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _showBulkSetDialog,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border.all(color: AppColors.surfaceContainerHigh),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.settings_input_component_outlined, color: AppColors.secondary, size: 20),
                    const SizedBox(width: 16),
                    Text(
                      'EXECUTE_BATCH_CONFIGURATION',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.onSurface,
                        letterSpacing: 1,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_outlined, size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'NO_ACTIVE_UNITS_DETECTED'.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          const Text('MISSION SETUP DATA REQUIRED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildSpgCard(
    BuildContext context,
    dynamic es,
    dynamic spg,
    dynamic spb,
    AvailableProductsLoaded productState,
    StockState stockState,
  ) {
    final spgName = spg?.name ?? es.spgId;
    final spbName = spb?.name ?? (es.spbId != null ? es.spbId : null);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          collapsedIconColor: AppColors.onSurfaceVariant,
          iconColor: AppColors.secondary,
          leading: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border.fromBorderSide(BorderSide(color: AppColors.surfaceContainerHigh)),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 18),
          ),
          title: Text(
            spgName.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
          ),
          subtitle: Text(
            spbName != null ? 'COMMANDER: ${spbName.toUpperCase()}' : 'NO COMMANDER ASSIGNED',
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Text('ASSET_DESC', style: TextStyle(fontSize: 8, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                  SizedBox(width: 80, child: Text('QTY', textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1))),
                  SizedBox(width: 60, child: Text('WH_AVAIL', textAlign: TextAlign.right, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 1))),
                ],
              ),
            ),
            ...productState.assignedProducts.map((ep) {
              final product = productState.products.firstWhereOrNull((p) => p.id == ep.productId);
              final productName = product?.name ?? ep.productId;

              final currentQty = _distributions[es.spgId]?[ep.productId] ?? _getCurrentInitial(stockState, es.spgId, ep.productId);
              final warehouseAvailable = _calculateWarehouseAvailable(stockState, ep.productId, es.spgId);
              final exceeded = currentQty > warehouseAvailable;

              return _buildDistributionRow(context, es.spgId, ep.productId, productName, currentQty, warehouseAvailable, exceeded);
            }),
            const SizedBox(height: 20),
            _buildSpgSummary(context, es.spgId, productState, stockState),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionRow(
    BuildContext context,
    String spgId,
    String productId,
    String productName,
    int currentQty,
    int warehouseAvailable,
    bool exceeded,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(productName.toUpperCase(), style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w900, fontSize: 12)),
          ),
          SizedBox(
            width: 80,
            child: Column(
              children: [
                TextField(
                  controller: TextEditingController(text: currentQty.toString())..selection = TextSelection.fromPosition(TextPosition(offset: currentQty.toString().length)),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: exceeded ? AppColors.error : AppColors.secondary, fontWeight: FontWeight.w900, fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.surfaceContainerHigh)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: exceeded ? AppColors.error : AppColors.surfaceContainerHigh)),
                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.secondary, width: 2)),
                  ),
                  onChanged: (val) {
                    final newValue = int.tryParse(val) ?? 0;
                    _distributions[spgId] ??= {};
                    _distributions[spgId]![productId] = newValue;
                    setState(() {});
                  },
                ),
                if (exceeded)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), border: Border.all(color: AppColors.error)),
                    child: const Text('EXCEEDS', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: AppColors.error)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: Text(
              warehouseAvailable.toString(),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: exceeded ? AppColors.error : AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpgSummary(BuildContext context, String spgId, AvailableProductsLoaded productState, StockState stockState) {
    int totalInitial = 0;

    for (final ep in productState.assignedProducts) {
      totalInitial += _distributions[spgId]?[ep.productId] ?? _getCurrentInitial(stockState, spgId, ep.productId);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: AppColors.surface, border: Border(left: BorderSide(color: AppColors.primary, width: 4))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SUPPLY_TELEMETRY', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 8, letterSpacing: 2, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text('TOTAL_INITIAL_ALLOCATED: $totalInitial units'.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppColors.onSurface, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    final stockState = context.read<StockBloc>().state;
    final hasExceeded = _hasAnyExceeded(stockState);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(color: AppColors.surfaceContainerLowest, border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh))),
      child: ElevatedButton(
        onPressed: (_isSaving || hasExceeded) ? null : _saveDistributions,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 60),
          backgroundColor: hasExceeded ? AppColors.surfaceContainerHigh : AppColors.primary,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(
                hasExceeded ? 'WAREHOUSE_LIMIT_EXCEEDED' : 'COMMIT_DISTRIBUTION_DATA',
                style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
      ),
    );
  }
}