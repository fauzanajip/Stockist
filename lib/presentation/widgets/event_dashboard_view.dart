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

  const EventDashboardView({
    super.key,
    required this.event,
  });

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        app_formatters.Formatters.formatDate(event.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
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
                          (m.type == MutationType.initial ||
                              m.type == MutationType.topup),
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
                            'WAREHOUSE',
                            warehouseStock.toString(),
                            AppColors.primary,
                            Icons.inventory_2_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'SOLD',
                            totalSold.toString(),
                            AppColors.secondary,
                            Icons.local_fire_department_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.onSurface.withOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL REVENUE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.onSurfaceVariant,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                app_formatters.Formatters.formatCurrency(
                                  totalRevenue,
                                ),
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.secondary,
                                    ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.secondary.withOpacity(
                              0.1,
                            ),
                            child: const Icon(
                              Icons.payments_outlined,
                              color: AppColors.secondary,
                            ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.onSurface.withOpacity(0.05)),
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
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
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
        if (epState is! AvailableProductsLoaded ||
            epState.assignedProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel(context, 'PRODUCT PERFORMANCE'),
            const SizedBox(height: 16),
            ...epState.assignedProducts.map((ep) {
              final product = epState.products.firstWhere(
                (p) => p.id == ep.productId,
              );
              return _buildProductRow(context, product, ep);
            }).toList(),
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
                      m.productId == ep.productId &&
                      m.type == MutationType.distributorToEvent,
                )
                .fold(0, (sum, m) => sum + m.qty);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'SKU: ${product.sku}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildMiniStat('IN', totalIn.toString(), AppColors.primary),
                  const SizedBox(width: 16),
                  _buildMiniStat(
                    'SOLD',
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
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildManagementActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(context, 'MANAGEMENT'),
        const SizedBox(height: 16),
        _buildActionTile(
          context,
          icon: Icons.people_outline,
          title: 'Daftar SPG',
          subtitle: 'Absensi dan performa individu',
          color: AppColors.primary,
          onTap: () => context.pushNamed(
            'spg_list',
            pathParameters: {'eventId': event.id},
          ),
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          context,
          icon: Icons.settings_outlined,
          title: 'Setup Event',
          subtitle: 'Konfigurasi produk & petugas',
          color: AppColors.onSurfaceVariant,
          onTap: () => context.pushNamed(
            'event_setup',
            pathParameters: {'eventId': event.id},
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 1.5,
      ),
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
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
