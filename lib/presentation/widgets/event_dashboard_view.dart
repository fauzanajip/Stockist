import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/formatters.dart' as app_formatters;
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/stock_mutation_entity.dart';
import '../blocs/stock_bloc/stock_bloc.dart';
import '../blocs/stock_bloc/stock_state.dart';
import '../blocs/sales_bloc/sales_bloc.dart';
import '../blocs/sales_bloc/sales_state.dart';
import '../blocs/cash_bloc/cash_bloc.dart';
import '../blocs/cash_bloc/cash_state.dart';
import '../blocs/event_product_bloc/event_product_bloc.dart';
import '../blocs/event_product_bloc/event_product_state.dart';

class EventDashboardView extends StatelessWidget {
  final EventEntity event;

  const EventDashboardView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const SizedBox(height: 28),
          _buildQuickStats(context),
          const SizedBox(height: 32),
          _buildProductPerformance(context),
          const SizedBox(height: 32),
          _buildManagementActions(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.hub_outlined, color: AppColors.primary, size: 14),
            const SizedBox(width: 8),
            Text(
              'MISSION TELEMETRY ACTIVE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          event.name.toUpperCase(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.event_seat_outlined, size: 14, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              app_formatters.Formatters.formatDate(event.date).toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
        return BlocBuilder<SalesBloc, SalesState>(
          builder: (context, salesState) {
            return BlocBuilder<CashBloc, CashState>(
              builder: (context, cashState) {
                final totalIn = stockState.mutations
                    .where((m) => m.type == MutationType.distributorToEvent)
                    .fold(0, (sum, m) => sum + m.qty);

                final totalDistributed = stockState.mutations
                    .where(
                      (m) =>
                          m.spgId != 'WAREHOUSE' &&
                          (m.type == MutationType.initial || m.type == MutationType.topup),
                    )
                    .fold(0, (sum, m) => sum + m.qty);

                final totalReturn = stockState.mutations
                    .where((m) => m.type == MutationType.returnMutation)
                    .fold(0, (sum, m) => sum + m.qty);

                final warehouseStock = totalIn - totalDistributed + totalReturn;

                final totalSold = salesState.allSales.fold(
                  0,
                  (sum, s) => sum + s.qtySold,
                );

                final totalRevenue = cashState.allCash.fold(
                  0.0,
                  (sum, c) => sum + c.actualCash + c.qrisReceived,
                );

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'WAREHOUSE INVENTORY',
                            warehouseStock.toString(),
                            AppColors.primary,
                            Icons.inventory_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'ASSETS SOLD',
                            totalSold.toString(),
                            AppColors.secondary,
                            Icons.local_fire_department_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        border: Border.all(color: AppColors.surfaceContainerHigh),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CASH TELEMETRY (ACTUAL + QRIS)',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.onSurfaceVariant,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                app_formatters.Formatters.formatCurrency(totalRevenue),
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.secondary,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.analytics_outlined,
                            color: AppColors.onSurfaceVariant,
                            size: 24,
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

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1,
                ),
              ),
              Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPerformance(BuildContext context) {
    return BlocBuilder<EventProductBloc, EventProductState>(
      builder: (context, epState) {
        if (epState is! AvailableProductsLoaded || epState.assignedProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel(context, 'PRODUCT TELEMETRY'),
            const SizedBox(height: 16),
            ...epState.assignedProducts.map((ep) {
              final product = epState.products.cast<dynamic>().firstWhere(
                    (p) => p.id == ep.productId,
                    orElse: () => null,
                  );
              if (product == null) return const SizedBox.shrink();
              return _buildProductRow(context, product, ep);
            }),
          ],
        );
      },
    );
  }

  Widget _buildProductRow(BuildContext context, product, ep) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
        return BlocBuilder<SalesBloc, SalesState>(
          builder: (context, salesState) {
            final totalSold = salesState.allSales
                .where((s) => s.productId == ep.productId)
                .fold(0, (sum, s) => sum + s.qtySold);

            final totalIn = stockState.mutations
                .where(
                  (m) =>
                      m.productId == ep.productId && m.type == MutationType.distributorToEvent,
                )
                .fold(0, (sum, m) => sum + m.qty);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SIG: ${product.sku}'.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildMiniStat('INFLOW', totalIn.toString(), AppColors.primary),
                  const SizedBox(width: 20),
                  _buildMiniStat(
                    'OUTFLOW',
                    totalSold.toString(),
                    AppColors.secondary,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildManagementActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(context, 'COMMAND PROTOCOLS'),
        const SizedBox(height: 16),
        _buildActionTile(
          context,
          icon: Icons.shield_outlined,
          title: 'UNIT COMMANDERS',
          subtitle: 'Absensi dan performa SPG',
          color: AppColors.primary,
          onTap: () => context.pushNamed(
            'spg_list',
            pathParameters: {'eventId': event.id},
          ),
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          context,
          icon: Icons.swap_vert_circle_outlined,
          title: 'LOGISTICS HISTORY',
          subtitle: 'Audit mutasi inventaris',
          color: AppColors.secondary,
          onTap: () => context.pushNamed(
            'stock_history',
            pathParameters: {'eventId': event.id},
          ),
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          context,
          icon: Icons.tune_outlined,
          title: 'MISSION CONFIG',
          subtitle: 'Setup produk & petugas',
          color: AppColors.onSurfaceVariant,
          onTap: () => context.pushNamed(
            'event_setup',
            pathParameters: {'eventId': event.id},
          ),
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          context,
          icon: Icons.gps_fixed_outlined,
          title: 'OBJECTIVE TARGETS',
          subtitle: 'Set target operasional',
          color: AppColors.success,
          onTap: () => context.pushNamed(
            'sales_targets',
            pathParameters: {'eventId': event.id},
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Row(
      children: [
        Container(width: 4, height: 12, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.surfaceContainerHigh),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    subtitle.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
