import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import '../../../core/constants/app_theme.dart';
import '../../../domain/entities/spg_product_target_entity.dart';
import '../../blocs/event_spg_bloc/event_spg_bloc.dart';
import '../../blocs/event_spg_bloc/event_spg_event.dart';
import '../../blocs/event_spg_bloc/event_spg_state.dart';
import '../../blocs/event_product_bloc/event_product_bloc.dart';
import '../../blocs/event_product_bloc/event_product_event.dart';
import '../../blocs/event_product_bloc/event_product_state.dart';
import '../../blocs/spg_bloc/spg_bloc.dart';
import '../../blocs/spg_bloc/spg_state.dart';
import '../../blocs/sales_bloc/sales_bloc.dart';
import '../../blocs/sales_bloc/sales_state.dart';
import '../../blocs/spg_target_bloc/spg_target_bloc.dart';
import '../../blocs/spg_target_bloc/spg_target_event.dart';
import '../../blocs/spg_target_bloc/spg_target_state.dart';

class SalesTargetScreen extends StatefulWidget {
  final String eventId;

  const SalesTargetScreen({super.key, required this.eventId});

  @override
  State<SalesTargetScreen> createState() => _SalesTargetScreenState();
}

class _SalesTargetScreenState extends State<SalesTargetScreen> {
  final Map<String, Map<String, int>> _targets = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<EventSpgBloc>().add(LoadAvailableSpgs(eventId: widget.eventId));
    context.read<EventProductBloc>().add(LoadAvailableProducts(eventId: widget.eventId));
    context.read<SpgTargetBloc>().add(LoadTargetsByEvent(eventId: widget.eventId));
  }

  void _initializeTargetsFromState(List<SpgProductTargetEntity> loadedTargets) {
    for (final target in loadedTargets) {
      if (!_targets.containsKey(target.spgId)) {
        _targets[target.spgId] = {};
      }
      _targets[target.spgId]![target.productId] = target.targetQty;
    }
  }

  void _showBulkSetDialog() {
    final eventSpgState = context.read<EventSpgBloc>().state;
    final eventProductState = context.read<EventProductBloc>().state;

    if (eventSpgState is! AvailableSpgsLoaded ||
        eventProductState is! AvailableProductsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('DATA NOT READY. PLEASE WAIT.')),
      );
      return;
    }

    final selectedSpgIds = <String>[];
    final targetInputs = <String, int>{};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.batch_prediction_rounded, color: AppColors.secondary),
                          const SizedBox(width: 12),
                          Text(
                            'BATCH CONFIGURATION',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(bottomSheetContext),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'SELECT SPG UNITS',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setSheetState(() {
                                      if (selectedSpgIds.length == eventSpgState.assignedSpgs.length) {
                                        selectedSpgIds.clear();
                                      } else {
                                        selectedSpgIds.clear();
                                        selectedSpgIds.addAll(eventSpgState.assignedSpgs.map((es) => es.spgId));
                                      }
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    selectedSpgIds.length == eventSpgState.assignedSpgs.length ? 'DESELECT ALL' : 'SELECT ALL',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                children: [
                                  ...eventSpgState.assignedSpgs.map((es) {
                                    final spg = eventSpgState.spgs.firstWhereOrNull(
                                      (s) => s.id == es.spgId,
                                    );
                                    final isSelected = selectedSpgIds.contains(es.spgId);
                                    return CheckboxListTile(
                                      title: Text(
                                        (spg?.name ?? es.spgId).toUpperCase(),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      value: isSelected,
                                      activeColor: AppColors.secondary,
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
                            const SizedBox(height: 24),
                            Text(
                              'SET PRODUCT TARGETS (UNITS)',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            ...eventProductState.assignedProducts.map((ep) {
                              final product = eventProductState.products.firstWhereOrNull(
                                (p) => p.id == ep.productId,
                              );
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.surfaceContainerHigh, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          (product?.name ?? ep.productId).toUpperCase(),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      SizedBox(
                                        width: 100,
                                        child: TextFormField(
                                          initialValue: targetInputs[ep.productId]?.toString() ?? '0',
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                            filled: true,
                                            fillColor: AppColors.surface,
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: AppColors.surfaceContainerHigh),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: AppColors.secondary, width: 2),
                                            ),
                                          ),
                                          onChanged: (val) {
                                            targetInputs[ep.productId] = int.tryParse(val) ?? 0;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    // Action Footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(bottomSheetContext),
                              child: const Text('CANCEL'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: selectedSpgIds.isEmpty
                                  ? null
                                  : () {
                                      _applyBulkTargets(selectedSpgIds, targetInputs);
                                      Navigator.pop(bottomSheetContext);
                                    },
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

  void _applyBulkTargets(List<String> spgIds, Map<String, int> productTargets) {
    setState(() {
      for (final spgId in spgIds) {
        if (!_targets.containsKey(spgId)) {
          _targets[spgId] = {};
        }
        for (final entry in productTargets.entries) {
          _targets[spgId]![entry.key] = entry.value;
        }
      }
    });
  }

  void _saveTargets() {
    final eventSpgState = context.read<EventSpgBloc>().state;
    final eventProductState = context.read<EventProductBloc>().state;

    if (eventSpgState is! AvailableSpgsLoaded ||
        eventProductState is! AvailableProductsLoaded) {
      return;
    }

    setState(() => _isSaving = true);

    final targetsToSave = <SpgProductTargetEntity>[];
    for (final spgId in _targets.keys) {
      for (final productId in _targets[spgId]!.keys) {
        targetsToSave.add(
          SpgProductTargetEntity(
            id: '',
            eventId: widget.eventId,
            spgId: spgId,
            productId: productId,
            targetQty: _targets[spgId]![productId] ?? 0,
          ),
        );
      }
    }

    context.read<SpgTargetBloc>().add(
      BulkCreateOrUpdateTargetsEvent(targets: targetsToSave),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TARGET PENJUALAN'), // Uppercase for tactical feel
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: _loadData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<SpgTargetBloc, SpgTargetState>(
        listener: (context, state) {
          if (state is SpgTargetsBulkSaved) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Target berhasil disimpan')),
            );
          }
          if (state is SpgTargetError) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
          if (state is SpgTargetsLoaded) {
            _initializeTargetsFromState(state.targets);
          }
        },
        builder: (context, targetState) {
          return BlocBuilder<EventSpgBloc, EventSpgState>(
            builder: (context, spgState) {
              return BlocBuilder<EventProductBloc, EventProductState>(
                builder: (context, productState) {
                  return BlocBuilder<SalesBloc, SalesState>(
                    builder: (context, salesState) {
                      if (spgState is EventSpgLoading ||
                          productState is EventProductLoading ||
                          targetState is SpgTargetLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (spgState is! AvailableSpgsLoaded ||
                          productState is! AvailableProductsLoaded) {
                        return _buildEmptyState();
                      }

                      return CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(child: _buildToolbar(context)),
                          if (spgState.assignedSpgs.isEmpty)
                            SliverFillRemaining(child: _buildEmptyState())
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final es = spgState.assignedSpgs[index];
                                    final spg = spgState.spgs.firstWhereOrNull((s) => s.id == es.spgId);
                                    final spb = spgState.spbs.firstWhereOrNull((s) => s.id == es.spbId);

                                    return _buildSpgCard(
                                      context,
                                      es,
                                      spg,
                                      spb,
                                      productState,
                                      salesState,
                                    );
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
          );
        },
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FIELD OPERATIONS COMMAND',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _showBulkSetDialog,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.edit_note_rounded, color: AppColors.secondary, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'BATCH CONFIGURATION',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
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
          Icon(
            Icons.track_changes_outlined,
            size: 64,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada SPG atau Produk',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Setup Event terlebih dahulu'),
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
    SalesState salesState,
  ) {
    final spgName = spg?.name ?? es.spgId;
    final spbName = spb?.name ?? (es.spbId != null ? es.spbId : null);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.surfaceContainerHigh, width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          collapsedIconColor: AppColors.onSurfaceVariant,
          iconColor: AppColors.secondary,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20),
          ),
          title: Text(
            spgName.toUpperCase(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
          ),
          subtitle: Text(
            spbName != null ? 'SUPERVISOR: $spbName' : 'NO SUPERVISOR ASSIGNED',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                ),
          ),
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'PRODUCT ASSET',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      'TARGET',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      'ACTUAL',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            ...productState.assignedProducts.map((ep) {
              final product = productState.products.firstWhereOrNull(
                (p) => p.id == ep.productId,
              );
              final productName = product?.name ?? ep.productId;

              final currentTarget = _targets[es.spgId]?[ep.productId] ?? 0;
              final sold = salesState.allSales
                  .where((s) => s.spgId == es.spgId && s.productId == ep.productId)
                  .fold(0, (sum, s) => sum + s.qtySold);

              return _buildTargetRow(
                context,
                es.spgId,
                ep.productId,
                productName,
                currentTarget,
                sold,
              );
            }),
            const SizedBox(height: 12),
            _buildSpgSummary(context, es.spgId, productState, salesState),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetRow(
    BuildContext context,
    String spgId,
    String productId,
    String productName,
    int currentTarget,
    int sold,
  ) {
    final percentage = currentTarget > 0 ? (sold / currentTarget * 100).clamp(0.0, 100.0) : 0.0;
    final color = percentage < 50
        ? AppColors.error
        : percentage < 80
            ? AppColors.warning
            : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceContainerHigh.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              productName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          SizedBox(
            width: 70,
            child: TextField(
              controller: TextEditingController(text: currentTarget.toString())
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: currentTarget.toString().length),
                ),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
              decoration: const InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceContainerLowest,
                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.secondary, width: 1.5),
                ),
              ),
              onChanged: (val) {
                final newValue = int.tryParse(val) ?? 0;
                _targets[spgId] ??= {};
                _targets[spgId]![productId] = newValue;
                // No setState here to avoid re-rendering while typing
                // but we need it for the percentage calculation.
                // Usually for numeric inputs in list, a debounce or local state is better.
                // For now, let's keep it simple as the user might want immediate feedback.
                setState(() {});
              },
            ),
          ),
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Text(
                  sold.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (currentTarget > 0)
                  Container(
                    height: 2,
                    margin: const EdgeInsets.only(top: 2),
                    width: 24 * (percentage / 100),
                    color: color,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpgSummary(
    BuildContext context,
    String spgId,
    AvailableProductsLoaded productState,
    SalesState salesState,
  ) {
    int totalTarget = 0;
    int totalSold = 0;

    for (final ep in productState.assignedProducts) {
      totalTarget += _targets[spgId]?[ep.productId] ?? 0;
      totalSold += salesState.allSales
          .where((s) => s.spgId == spgId && s.productId == ep.productId)
          .fold(0, (sum, s) => sum + s.qtySold);
    }

    final percentage = totalTarget > 0 ? (totalSold / totalTarget * 100).clamp(0.0, 100.0) : 0.0;
    final color = percentage < 50
        ? AppColors.error
        : percentage < 80
            ? AppColors.warning
            : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COMPLETION TELEMETRY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 9,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AGGREGATE TARGET: $totalTarget units | ACTUAL: $totalSold',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: AppColors.onSurface,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                totalTarget > 0 ? '${percentage.toInt()}%' : '--',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: totalTarget > 0 ? color : AppColors.onSurfaceVariant,
                      letterSpacing: -1,
                    ),
              ),
              Text(
                'QUOTA PHASE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 8,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveTargets,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                'COMMIT TARGET DATA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}