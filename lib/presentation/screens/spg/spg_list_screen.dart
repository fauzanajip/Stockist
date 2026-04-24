import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart' as app_formatters;
import '../../../domain/entities/event_spg_entity.dart';
import '../../../domain/entities/spb_entity.dart';
import '../../../domain/entities/stock_mutation_entity.dart';
import '../../../core/utils/stock_calculator.dart';
import '../../blocs/event_spg_bloc/event_spg_bloc.dart';
import '../../blocs/event_spg_bloc/event_spg_event.dart';
import '../../blocs/event_spg_bloc/event_spg_state.dart';
import '../../blocs/spg_bloc/spg_bloc.dart';
import '../../blocs/spg_bloc/spg_event.dart';
import '../../blocs/spg_bloc/spg_state.dart';
import '../../blocs/stock_bloc/stock_bloc.dart';
import '../../blocs/stock_bloc/stock_event.dart';
import '../../blocs/stock_bloc/stock_state.dart';
import '../../blocs/sales_bloc/sales_bloc.dart';
import '../../blocs/sales_bloc/sales_event.dart';
import '../../blocs/sales_bloc/sales_state.dart';
import '../../blocs/cash_bloc/cash_bloc.dart';
import '../../blocs/cash_bloc/cash_event.dart';
import '../../blocs/cash_bloc/cash_state.dart';
import '../../blocs/event_product_bloc/event_product_bloc.dart';
import '../../blocs/event_product_bloc/event_product_event.dart';
import '../../blocs/event_product_bloc/event_product_state.dart';
import '../../blocs/spg_target_bloc/spg_target_bloc.dart';
import '../../blocs/spg_target_bloc/spg_target_event.dart';
import '../../blocs/spg_target_bloc/spg_target_state.dart';
import '../../../domain/entities/spg_product_target_entity.dart';

enum _SpgSortMode { name, spb }

class SpgListScreen extends StatefulWidget {
  final String eventId;

  const SpgListScreen({super.key, required this.eventId});

  @override
  State<SpgListScreen> createState() => _SpgListScreenState();
}

class _SpgListScreenState extends State<SpgListScreen> {
  _SpgSortMode _sortMode = _SpgSortMode.name;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<EventSpgBloc>().add(
      LoadAvailableSpgs(eventId: widget.eventId),
    );
    context.read<SpgBloc>().add(LoadAllSpqs());
    context.read<StockBloc>().add(LoadStockByEvent(eventId: widget.eventId));
    context.read<SalesBloc>().add(LoadAllSalesByEvent(eventId: widget.eventId));
    context.read<CashBloc>().add(LoadAllCashByEvent(eventId: widget.eventId));
    context.read<EventProductBloc>().add(
      LoadAvailableProducts(eventId: widget.eventId),
    );
    context.read<SpgTargetBloc>().add(
      LoadTargetsByEvent(eventId: widget.eventId),
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
              'UNIT_MONITORING',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
            ),
            const Text(
              'FLEET TELEMETRY',
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
            icon: const Icon(Icons.refresh_rounded, size: 20),
            onPressed: _loadData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<EventSpgBloc, EventSpgState>(
        builder: (context, state) {
          if (state is EventSpgLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is EventSpgError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text('SYSTEM ERROR: ${state.message.toUpperCase()}'),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _loadData,
                    child: const Text('RETRY SYNC'),
                  ),
                ],
              ),
            );
          }
          if (state is AvailableSpgsLoaded) {
            return BlocBuilder<SpgBloc, SpgState>(
              builder: (context, spgState) {
                final sortedSpgs = _sortEventSpgs(
                  state.assignedSpgs,
                  state.spbs,
                  spgState,
                );

                if (sortedSpgs.isEmpty) {
                  return _buildEmptyState(context);
                }

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildOperationalToolbar()),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return SpgDashboardCard(
                            eventId: widget.eventId,
                            eventSpg: sortedSpgs[index],
                            spbs: state.spbs,
                          );
                        }, childCount: sortedSpgs.length),
                      ),
                    ),
                  ],
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildOperationalToolbar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.sort_rounded,
                size: 14,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'SORT PRIORITY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                  fontSize: 9,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSortChip('UNIT NAME', _SpgSortMode.name),
              const SizedBox(width: 8),
              _buildSortChip('SPB COORDINATOR', _SpgSortMode.spb),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.surfaceContainerHigh),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            size: 48,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'NO MISSION UNITS DETECTED'.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            'EXECUTE UNIT REGISTRATION IN MISSION SETUP'.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, _SpgSortMode mode) {
    final isSelected = _sortMode == mode;
    return InkWell(
      onTap: () => setState(() => _sortMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surfaceContainerLowest,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.surfaceContainerHigh,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  List<EventSpgEntity> _sortEventSpgs(
    List<EventSpgEntity> eventSpgs,
    List<SpbEntity> spbs,
    SpgState spgState,
  ) {
    if (spgState is! SpqsLoaded) return eventSpgs;

    final sorted = List<EventSpgEntity>.from(eventSpgs);

    if (_sortMode == _SpgSortMode.name) {
      sorted.sort((a, b) {
        final spgA = spgState.spqs.firstWhereOrNull((s) => s.id == a.spgId);
        final spgB = spgState.spqs.firstWhereOrNull((s) => s.id == b.spgId);
        final nameA = spgA?.name ?? '';
        final nameB = spgB?.name ?? '';
        return nameA.compareTo(nameB);
      });
    } else {
      sorted.sort((a, b) {
        final spbA = spbs.firstWhereOrNull((s) => s.id == a.spbId);
        final spbB = spbs.firstWhereOrNull((s) => s.id == b.spbId);
        final nameA = spbA?.name ?? '';
        final nameB = spbB?.name ?? '';
        if (a.spbId == null && b.spbId != null) return 1;
        if (a.spbId != null && b.spbId == null) return -1;
        return nameA.compareTo(nameB);
      });
    }

    return sorted;
  }
}

class SpgDashboardCard extends StatelessWidget {
  final String eventId;
  final EventSpgEntity eventSpg;
  final List<SpbEntity> spbs;

  const SpgDashboardCard({
    super.key,
    required this.eventId,
    required this.eventSpg,
    required this.spbs,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return "S";
    final parts = name.trim().split(" ");
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpgBloc, SpgState>(
      builder: (context, spgState) {
        if (spgState is! SpqsLoaded) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final spg = spgState.spqs.firstWhere((s) => s.id == eventSpg.spgId);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.zero,
            border: Border.all(color: AppColors.surfaceContainerHigh, width: 1),
          ),
          child: Column(
            children: [
              Container(
                height: 2,
                width: double.infinity,
                color: AppColors.secondary,
              ),
              InkWell(
                onTap: () => context.pushNamed(
                  'spg_detail',
                  pathParameters: {'eventId': eventId, 'spgId': spg.id},
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.zero,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _getInitials(spg.name),
                              style: const TextStyle(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  spg.name.toUpperCase(),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                ),
                                if (eventSpg.spbId != null)
                                  Builder(
                                    builder: (context) {
                                      final spb = spbs.firstWhereOrNull(
                                        (s) => s.id == eventSpg.spbId,
                                      );
                                      final spbName =
                                          spb?.name ?? eventSpg.spbId!;
                                      return Text(
                                        'SPB_LOG: ${spbName.toUpperCase()}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                          _buildStatusChip(context, eventId, spg.id),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _SpgDashboardStats(eventId: eventId, spgId: spg.id),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(BuildContext context, String eventId, String spgId) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
        return BlocBuilder<SalesBloc, SalesState>(
          builder: (context, salesState) {
            return BlocBuilder<CashBloc, CashState>(
              builder: (context, cashState) {
                return BlocBuilder<EventProductBloc, EventProductState>(
                  builder: (context, epState) {
                    bool hasData = stockState.mutations.any(
                      (m) => m.spgId == spgId,
                    );
                    bool isMatch = false;
                    bool isLoading =
                        stockState.isLoading ||
                        salesState.isLoading ||
                        cashState.isLoading;

                    if (hasData) {
                      final spgSales = salesState.allSales.where(
                        (s) => s.spgId == spgId,
                      );
                      final spgCash = cashState.allCash
                          .where((c) => c.spgId == spgId)
                          .firstOrNull;
                      final cashTotal =
                          (spgCash?.cashReceived ?? 0) +
                          (spgCash?.qrisReceived ?? 0);

                      double expectedCash = 0;
                      if (epState is AvailableProductsLoaded) {
                        for (final sale in spgSales) {
                          final ep = epState.assignedProducts.firstWhereOrNull(
                            (p) => p.productId == sale.productId,
                          );
                          if (ep != null) {
                            expectedCash += sale.qtySold * ep.price;
                          }
                        }
                      }

                      isMatch = (cashTotal - expectedCash) == 0;
                    }

                    if (isLoading) return _chip("SYNCING", Colors.grey);
                    if (!hasData)
                      return _chip("NO_DATA", AppColors.onSurfaceVariant);

                    return _chip(
                      isMatch ? "READY" : "REVIEW",
                      isMatch ? AppColors.success : AppColors.warning,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.zero,
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.zero,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpgDashboardStats extends StatelessWidget {
  final String eventId;
  final String spgId;

  const _SpgDashboardStats({required this.eventId, required this.spgId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
        return BlocBuilder<SalesBloc, SalesState>(
          builder: (context, salesState) {
            return BlocBuilder<CashBloc, CashState>(
              builder: (context, cashState) {
                final spgMutations = stockState.mutations
                    .where((m) => m.spgId == spgId)
                    .toList();
                final spgSales = salesState.allSales
                    .where((s) => s.spgId == spgId)
                    .toList();
                final spgCash = cashState.allCash
                    .where((c) => c.spgId == spgId)
                    .firstOrNull;

                final initialQty = spgMutations
                    .where((m) => m.type == MutationType.initial)
                    .fold(0, (sum, m) => sum + m.qty);
                final topupQty = spgMutations
                    .where((m) => m.type == MutationType.topup)
                    .fold(0, (sum, m) => sum + m.qty);
                final returnQty = spgMutations
                    .where((m) => m.type == MutationType.returnMutation)
                    .fold(0, (sum, m) => sum + m.qty);

                final totalGiven = StockCalculator.calculateTotalGiven(
                  initialQty: initialQty,
                  topupQty: topupQty,
                );
                final totalReturn = StockCalculator.calculateTotalReturn(
                  returnQty: returnQty,
                );
                final totalTerjual = spgSales.fold(
                  0,
                  (sum, s) => sum + s.qtySold,
                );
                final sisaSystem = StockCalculator.calculateSisaSystem(
                  totalDikasih: totalGiven,
                  totalReturn: totalReturn,
                  totalTerjual: totalTerjual,
                );

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.zero,
                        border: Border.all(
                          color: AppColors.surfaceContainerHigh,
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildStatItem(
                            context,
                            'DIST',
                            initialQty + topupQty,
                            AppColors.success,
                          ),
                          Container(
                            width: 1,
                            height: 24,
                            color: AppColors.surfaceContainerHigh,
                          ),
                          const SizedBox(width: 12),
                          _buildStatItem(
                            context,
                            'SOLD',
                            totalTerjual,
                            AppColors.secondary,
                          ),
                          Container(
                            width: 1,
                            height: 24,
                            color: AppColors.surfaceContainerHigh,
                          ),
                          const SizedBox(width: 12),
                          _buildStatItem(
                            context,
                            'STOCK',
                            sisaSystem,
                            AppColors.onSurface,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<EventProductBloc, EventProductState>(
                      builder: (context, epState) {
                        double expectedCash = 0;
                        if (epState is AvailableProductsLoaded) {
                          for (final sale in spgSales) {
                            final ep = epState.assignedProducts
                                .firstWhereOrNull(
                                  (p) => p.productId == sale.productId,
                                );
                            if (ep != null) {
                              expectedCash += sale.qtySold * ep.price;
                            }
                          }
                        }

                        final cashTunai = spgCash?.cashReceived ?? 0;
                        final qris = spgCash?.qrisReceived ?? 0;
                        final totalActual = cashTunai + qris;
                        final surplus = totalActual - expectedCash;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.zero,
                            border: Border.all(
                              color: AppColors.surfaceContainerHigh,
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    size: 14,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'EXPECTED REVENUE',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 9,
                                          letterSpacing: 1.0,
                                        ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    app_formatters.Formatters.formatCurrency(
                                      expectedCash,
                                    ),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.onSurface,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(
                                  height: 1,
                                  color: AppColors.surfaceContainerHigh,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'CASH_SETTLEMENT',
                                    style: _ledgerLabelStyle(context),
                                  ),
                                  const Spacer(),
                                  Text(
                                    app_formatters.Formatters.formatCurrency(
                                      cashTunai,
                                    ),
                                    style: _ledgerValueStyle(context),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    'QRIS_SETTLEMENT',
                                    style: _ledgerLabelStyle(context),
                                  ),
                                  const Spacer(),
                                  Text(
                                    app_formatters.Formatters.formatCurrency(
                                      qris,
                                    ),
                                    style: _ledgerValueStyle(context),
                                  ),
                                ],
                              ),
                              const Divider(
                                height: 16,
                                color: AppColors.surfaceContainerHigh,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.payments_rounded,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'TOTAL SETTLEMENT',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 9,
                                          letterSpacing: 1.0,
                                        ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    app_formatters.Formatters.formatCurrency(
                                      totalActual,
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ],
                              ),
                              if (surplus != 0)
                                Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (surplus > 0
                                                ? AppColors.success
                                                : AppColors.error)
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        surplus > 0
                                            ? Icons.add_circle_outline
                                            : Icons.remove_circle_outline,
                                        size: 10,
                                        color: surplus > 0
                                            ? AppColors.success
                                            : AppColors.error,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        surplus > 0
                                            ? 'REVENUE SURPLUS'
                                            : 'SETTLEMENT DEFICIT',
                                        style: TextStyle(
                                          color: surplus > 0
                                              ? AppColors.success
                                              : AppColors.error,
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        app_formatters
                                            .Formatters.formatCurrency(
                                          surplus.abs(),
                                        ),
                                        style: TextStyle(
                                          color: surplus > 0
                                              ? AppColors.success
                                              : AppColors.error,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        title: const Text(
                          'VIEW MISSION DETAILS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        children: [
                          BlocBuilder<SpgTargetBloc, SpgTargetState>(
                            builder: (context, targetState) {
                              if (targetState is! SpgTargetsLoaded) {
                                return const SizedBox.shrink();
                              }

                              final spgTargets = targetState.targets
                                  .where((t) => t.spgId == spgId)
                                  .toList();

                              if (spgTargets.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              int totalTarget = spgTargets.fold(
                                0,
                                (sum, t) => sum + t.targetQty,
                              );
                              if (totalTarget == 0) {
                                return const SizedBox.shrink();
                              }

                              final totalSold = spgSales.fold(
                                0,
                                (sum, s) => sum + s.qtySold,
                              );
                              final percentage = (totalSold / totalTarget * 100)
                                  .clamp(0, 100);
                              final color = percentage < 50
                                  ? AppColors.error
                                  : percentage < 80
                                  ? AppColors.warning
                                  : AppColors.success;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLowest,
                                  borderRadius: BorderRadius.zero,
                                  border: Border.all(
                                    color: AppColors.surfaceContainerHigh,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.track_changes_rounded,
                                          size: 14,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'MISSION STATUS',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color:
                                                    AppColors.onSurfaceVariant,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 9,
                                                letterSpacing: 1.0,
                                              ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${percentage.toInt()}%',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                            color: color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    LinearProgressIndicator(
                                      value: percentage / 100,
                                      backgroundColor: color.withOpacity(0.1),
                                      color: color,
                                      minHeight: 6,
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _miniLabel(context, 'SOLD: $totalSold'),
                                        _miniLabel(
                                          context,
                                          'QUOTA: $totalTarget',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.inventory_2_rounded,
                                size: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'PRODUCT INVENTORY MANIFEST',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 9,
                                      letterSpacing: 1.0,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          BlocBuilder<EventProductBloc, EventProductState>(
                            builder: (context, eventProductState) {
                              if (eventProductState
                                  is! AvailableProductsLoaded) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: LinearProgressIndicator(minHeight: 2),
                                );
                              }

                              final assignedProducts =
                                  eventProductState.assignedProducts;
                              if (assignedProducts.isEmpty) {
                                return const Text('No products assigned');
                              }

                              return Column(
                                children: assignedProducts.map((ep) {
                                  final product = eventProductState.products
                                      .firstWhereOrNull(
                                        (p) => p.id == ep.productId,
                                      );

                                  final prodMutations = spgMutations
                                      .where((m) => m.productId == ep.productId)
                                      .toList();
                                  final prodSales = spgSales
                                      .where((s) => s.productId == ep.productId)
                                      .toList();

                                  final pGiven = prodMutations
                                      .where(
                                        (m) =>
                                            m.type !=
                                            MutationType.returnMutation,
                                      )
                                      .fold(0, (sum, m) => sum + m.qty);
                                  final pReturn = prodMutations
                                      .where(
                                        (m) =>
                                            m.type ==
                                            MutationType.returnMutation,
                                      )
                                      .fold(0, (sum, m) => sum + m.qty);
                                  final pSold = prodSales.fold(
                                    0,
                                    (sum, s) => sum + s.qtySold,
                                  );
                                  final pSisa = pGiven - pReturn - pSold;

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLowest
                                            .withOpacity(0.5),
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              product?.name ?? 'Unknown',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                          _badge(
                                            'DST',
                                            pGiven.toString(),
                                            AppColors.success,
                                          ),
                                          const SizedBox(width: 6),
                                          _badge(
                                            'SLD',
                                            pSold.toString(),
                                            AppColors.secondary,
                                          ),
                                          const SizedBox(width: 6),
                                          _badge(
                                            'STK',
                                            pSisa.toString(),
                                            AppColors.onSurface,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
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
  }

  TextStyle _ledgerLabelStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
      color: AppColors.onSurfaceVariant,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
  }

  TextStyle _ledgerValueStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
      color: AppColors.onSurface,
      fontWeight: FontWeight.w900,
      fontSize: 11,
    );
  }

  Widget _miniLabel(BuildContext context, String text) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.onSurfaceVariant,
        fontSize: 9,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    dynamic value,
    Color color,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, String value, Color color) {
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.zero,
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 7,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
