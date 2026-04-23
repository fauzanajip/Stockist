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

class SpgListScreen extends StatefulWidget {
  final String eventId;

  const SpgListScreen({super.key, required this.eventId});

  @override
  State<SpgListScreen> createState() => _SpgListScreenState();
}

class _SpgListScreenState extends State<SpgListScreen> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPG List'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
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
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is AvailableSpgsLoaded) {
            if (state.assignedSpgs.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildSpgList(context, state.assignedSpgs, state.spbs);
          }
          return const Center(child: CircularProgressIndicator());
        },
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
            size: 64,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada SPG di event ini',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Setup SPG di Event Setup terlebih dahulu',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildSpgList(
    BuildContext context,
    List<EventSpgEntity> eventSpgs,
    List<SpbEntity> spbs,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: eventSpgs.length,
      itemBuilder: (context, index) {
        return SpgDashboardCard(
          eventId: widget.eventId,
          eventSpg: eventSpgs[index],
          spbs: spbs,
        );
      },
    );
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

  Color _getAvatarColor(String name) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      const Color(0xFF673AB7),
      const Color(0xFF009688),
    ];
    return colors[name.length % colors.length];
  }

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
          return const Card(child: ListTile(title: Text('Loading SPG...')));
        }

        final spg = spgState.spqs.firstWhere((s) => s.id == eventSpg.spgId);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withOpacity(0.5),
                    ],
                  ),
                ),
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
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: _getAvatarColor(
                              spg.name,
                            ).withOpacity(0.2),
                            child: Text(
                              _getInitials(spg.name),
                              style: TextStyle(
                                color: _getAvatarColor(spg.name),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  spg.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.2,
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
                                        'SPB: $spbName',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.onSurfaceVariant,
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

                    if (isLoading) return _chip("Syncing", Colors.grey);
                    if (!hasData)
                      return _chip("No Data", AppColors.onSurfaceVariant);

                    return _chip(
                      isMatch ? "Ready" : "Review",
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
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

                return Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    title: Column(
                      children: [
                        Row(
                          children: [
                            _buildStatItem(
                              context,
                              'Distributed',
                              totalGiven.toString(),
                              AppColors.success,
                            ),
                            const SizedBox(width: 12),
                            _buildStatItem(
                              context,
                              'Sold',
                              totalTerjual.toString(),
                              AppColors.secondary,
                            ),
                            const SizedBox(width: 12),
                            _buildStatItem(
                              context,
                              'Stock',
                              sisaSystem.toString(),
                              AppColors.onSurface,
                            ),
                          ],
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
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet_outlined,
                                        size: 16,
                                        color: AppColors.secondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'EXPECTED',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        app_formatters
                                            .Formatters.formatCurrency(
                                          expectedCash,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const SizedBox(width: 24),
                                      Text(
                                        'Cash Tunai',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        app_formatters
                                            .Formatters.formatCurrency(
                                          cashTunai,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const SizedBox(width: 24),
                                      Text(
                                        'QRIS',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        app_formatters
                                            .Formatters.formatCurrency(qris),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 16),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.payments_outlined,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'TOTAL ACTUAL',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        app_formatters
                                            .Formatters.formatCurrency(
                                          totalActual,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  if (surplus != 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            surplus > 0
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 14,
                                            color: surplus > 0
                                                ? AppColors.success
                                                : AppColors.error,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            surplus > 0 ? 'SURPLUS' : 'DEFICIT',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color: surplus > 0
                                                      ? AppColors.success
                                                      : AppColors.error,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            app_formatters
                                                .Formatters.formatCurrency(
                                              surplus.abs(),
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: surplus > 0
                                                      ? AppColors.success
                                                      : AppColors.error,
                                                  fontWeight: FontWeight.bold,
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
                      ],
                    ),
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PRODUCT BREAKDOWN',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.onSurfaceVariant,
                                  letterSpacing: 1.0,
                                ),
                          ),
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<EventProductBloc, EventProductState>(
                        builder: (context, eventProductState) {
                          if (eventProductState is! AvailableProductsLoaded) {
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
                                        m.type != MutationType.returnMutation,
                                  )
                                  .fold(0, (sum, m) => sum + m.qty);
                              final pReturn = prodMutations
                                  .where(
                                    (m) =>
                                        m.type == MutationType.returnMutation,
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
                                    borderRadius: BorderRadius.circular(8),
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
                                        'D',
                                        pGiven.toString(),
                                        AppColors.success,
                                      ),
                                      const SizedBox(width: 6),
                                      _badge(
                                        'T',
                                        pSold.toString(),
                                        AppColors.secondary,
                                      ),
                                      const SizedBox(width: 6),
                                      _badge(
                                        'S',
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
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
      width: 42,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
