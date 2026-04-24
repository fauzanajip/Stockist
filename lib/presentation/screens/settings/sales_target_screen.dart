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
        borderRadius: BorderRadius.zero,
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
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        border: Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.batch_prediction_rounded, color: AppColors.secondary, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'BATCH_CONFIGURATION_PROTOCOL',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close_fullscreen_outlined, size: 20),
                            onPressed: () => Navigator.pop(bottomSheetContext),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'FLEET_UNIT_SELECTION',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2,
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
                                    final spg = eventSpgState.spgs.firstWhereOrNull(
                                      (s) => s.id == es.spgId,
                                    );
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
                            Text(
                              'QUOTA_ALLOCATION_MATRIX (UNITS)',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
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
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLowest,
                                    border: Border.all(color: AppColors.surfaceContainerHigh),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          (product?.name ?? ep.productId).toUpperCase(),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.5,
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
                                          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.secondary, fontSize: 16),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                            filled: true,
                                            fillColor: AppColors.surface,
                                            border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.surfaceContainerHigh)),
                                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.surfaceContainerHigh)),
                                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.secondary, width: 2)),
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
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(bottomSheetContext),
                              style: OutlinedButton.styleFrom(
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('ABORT_OVERRIDE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
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
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                              child: Text('COMMIT_TO_${selectedSpgIds.length}_UNITS', style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CONTROL_QUOTA',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
            ),
            const Text(
              'MISSION_OBJECTIVE_TARGETS',
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
      body: BlocConsumer<SpgTargetBloc, SpgTargetState>(
        listener: (context, state) {
          if (state is SpgTargetsBulkSaved) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('TARGET_DATA_ARCHIVED: SUCCESS'),
                backgroundColor: AppColors.success,
              ),
            );
          }
          if (state is SpgTargetError) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('TELEMETRY_ERROR: ${state.message.toUpperCase()}')),
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
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
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
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal_outlined, size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'FIELD_OPERATIONS_COMMAND',
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
          const Icon(
            Icons.track_changes_outlined,
            size: 48,
            color: AppColors.onSurfaceVariant,
          ),
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
    SalesState salesState,
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
            child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
          ),
          title: Text(
            spgName.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
          subtitle: Text(
            spbName != null ? 'COMMANDER: ${spbName.toUpperCase()}' : 'NO COMMANDER ASSIGNED',
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
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
                    child: Text(
                      'ASSET_DESC',
                      style: TextStyle(
                            fontSize: 8,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      'QUOTA',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w900,
                            fontSize: 8,
                            letterSpacing: 1,
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
                            fontWeight: FontWeight.w900,
                            fontSize: 8,
                            letterSpacing: 1,
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
            const SizedBox(height: 20),
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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              productName.toUpperCase(),
              style: const TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
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
              style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
              decoration: const InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.surfaceContainerHigh)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.surfaceContainerHigh)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.secondary, width: 2)),
              ),
              onChanged: (val) {
                final newValue = int.tryParse(val) ?? 0;
                _targets[spgId] ??= {};
                _targets[spgId]![productId] = newValue;
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
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
                if (currentTarget > 0)
                  Container(
                    height: 2,
                    margin: const EdgeInsets.only(top: 4),
                    width: 24,
                    color: AppColors.surfaceContainerHigh,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 24 * (percentage / 100),
                      color: color,
                    ),
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
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COMPLETION_TELEMETRY',
                  style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 8,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'AGGREGATE_TARGET: $totalTarget units | ACTUAL: $totalSold'.toUpperCase(),
                  style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: totalTarget > 0 ? color : AppColors.onSurfaceVariant,
                      letterSpacing: -1,
                    ),
              ),
              const Text(
                'QUOTA_STATUS',
                style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
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
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveTargets,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 60),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text(
                'COMMIT_TARGET_DATA_PROTOCOL',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
      ),
    );
  }
}