import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:stockist/core/utils/formatters.dart' as app_formatters;
import 'package:stockist/domain/entities/stock_mutation_entity.dart';
import '../../../core/constants/app_theme.dart';
import '../../blocs/stock_bloc/stock_bloc.dart';
import '../../blocs/stock_bloc/stock_event.dart';
import '../../blocs/stock_bloc/stock_state.dart';
import '../../blocs/sales_bloc/sales_bloc.dart';
import '../../blocs/sales_bloc/sales_event.dart';
import '../../blocs/sales_bloc/sales_state.dart';
import '../../blocs/cash_bloc/cash_bloc.dart';
import '../../blocs/cash_bloc/cash_event.dart';
import '../../blocs/cash_bloc/cash_state.dart';
import '../../blocs/spg_bloc/spg_bloc.dart';
import '../../blocs/spg_bloc/spg_state.dart';

class SpgDetailScreen extends StatefulWidget {
  final String eventId;
  final String spgId;

  const SpgDetailScreen({
    super.key,
    required this.eventId,
    required this.spgId,
  });

  @override
  State<SpgDetailScreen> createState() => _SpgDetailScreenState();
}

class _SpgDetailScreenState extends State<SpgDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<StockBloc>().add(LoadStockByEvent(eventId: widget.eventId));
    context.read<SalesBloc>().add(LoadAllSalesByEvent(eventId: widget.eventId));
    context.read<CashBloc>().add(LoadAllCashByEvent(eventId: widget.eventId));
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPG Detail'),
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: BlocBuilder<SpgBloc, SpgState>(
        builder: (context, spgState) {
          if (spgState is! SpqsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final spg = spgState.spqs.firstWhereOrNull(
            (s) => s.id == widget.spgId,
          );
          if (spg == null) {
            return const Center(child: Text('SPG not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, spg.name),
                const SizedBox(height: 24),
                _buildSummaryDashboard(context),
                const SizedBox(height: 32),
                Text(
                  'TRANSACTIONS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                _buildActionGrid(context),
                const SizedBox(height: 32),
                Text(
                  'SETUP',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSetupAction(context),
                const SizedBox(height: 48),
                _buildClosingButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: _getAvatarColor(name).withOpacity(0.2),
          child: Text(
            _getInitials(name),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getAvatarColor(name),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              _buildStatusChip(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
        return BlocBuilder<SalesBloc, SalesState>(
          builder: (context, salesState) {
            return BlocBuilder<CashBloc, CashState>(
              builder: (context, cashState) {
                bool hasData = stockState.mutations.any(
                  (m) => m.spgId == widget.spgId,
                );
                bool isMatch = false;

                if (hasData) {
                  final spgSales = salesState.allSales.where(
                    (s) => s.spgId == widget.spgId,
                  );
                  final totalTerjual = spgSales.fold(
                    0,
                    (sum, s) => sum + s.qtySold,
                  );
                  final spgCash = cashState.allCash
                      .where((c) => c.spgId == widget.spgId)
                      .firstOrNull;
                  final cashTotal =
                      (spgCash?.cashReceived ?? 0) +
                      (spgCash?.qrisReceived ?? 0);

                  if (totalTerjual > 0) {
                    final expectedCash = totalTerjual * 10000;
                    isMatch = (cashTotal - expectedCash) == 0;
                  } else {
                    isMatch = cashTotal == 0;
                  }
                }

                final label = !hasData
                    ? "NO DATA"
                    : (isMatch ? "READY" : "REVIEW NEEDED");
                final color = !hasData
                    ? AppColors.onSurfaceVariant
                    : (isMatch ? AppColors.success : AppColors.warning);

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryDashboard(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
        return BlocBuilder<SalesBloc, SalesState>(
          builder: (context, salesState) {
            return BlocBuilder<CashBloc, CashState>(
              builder: (context, cashState) {
                final spgMutations = stockState.mutations
                    .where((m) => m.spgId == widget.spgId)
                    .toList();
                final spgSales = salesState.allSales
                    .where((s) => s.spgId == widget.spgId)
                    .toList();
                final spgCash = cashState.allCash
                    .where((c) => c.spgId == widget.spgId)
                    .firstOrNull;

                final totalGiven = spgMutations
                    .where((m) => m.type != MutationType.returnMutation)
                    .fold(0, (sum, m) => sum + m.qty);
                final totalReturn = spgMutations
                    .where((m) => m.type == MutationType.returnMutation)
                    .fold(0, (sum, m) => sum + m.qty);
                final totalSold = spgSales.fold(0, (sum, s) => sum + s.qtySold);
                final stockInHand = totalGiven - totalReturn - totalSold;
                final totalCash =
                    (spgCash?.cashReceived ?? 0) + (spgCash?.qrisReceived ?? 0);

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLargeStat(
                            'DISTRIBUTED',
                            totalGiven.toString(),
                            AppColors.success,
                          ),
                          _buildLargeStat(
                            'SOLD',
                            totalSold.toString(),
                            AppColors.secondary,
                          ),
                          _buildLargeStat(
                            'REMAINING',
                            stockInHand.toString(),
                            AppColors.onSurface,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'COLLECTED CASH',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            app_formatters.Formatters.formatCurrency(totalCash),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ],
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

  Widget _buildLargeStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildGridButton(
          context,
          icon: Icons.add_circle_outline,
          label: 'Tambah Stok',
          color: AppColors.success,
          route: 'topup',
        ),
        _buildGridButton(
          context,
          icon: Icons.refresh,
          label: 'Retur Stok',
          color: AppColors.warning,
          route: 'return',
        ),
        _buildGridButton(
          context,
          icon: Icons.bar_chart,
          label: 'Update Sales',
          color: AppColors.secondary,
          route: 'sales_input',
        ),
        _buildGridButton(
          context,
          icon: Icons.account_balance_wallet_outlined,
          label: 'Input Cash',
          color: AppColors.primary,
          route: 'cash_input',
        ),
      ],
    );
  }

  Widget _buildSetupAction(BuildContext context) {
    return _buildListButton(
      context,
      icon: Icons.app_registration,
      label: 'Distribusi Awal',
      subtitle: 'Set stok awal untuk event ini',
      color: AppColors.primary,
      route: 'initial_distribution',
    );
  }

  Widget _buildGridButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required String route,
  }) {
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.pushNamed(
          route,
          pathParameters: {'eventId': widget.eventId, 'spgId': widget.spgId},
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required String route,
  }) {
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        onTap: () => context.pushNamed(
          route,
          pathParameters: {'eventId': widget.eventId, 'spgId': widget.spgId},
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }

  Widget _buildClosingButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.pushNamed(
        'spg_closing',
        pathParameters: {'eventId': widget.eventId, 'spgId': widget.spgId},
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surfaceContainerHigh,
        foregroundColor: AppColors.onSurface,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline),
          SizedBox(width: 12),
          Text(
            'CLOSING SESSION',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
