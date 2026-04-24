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
import '../../blocs/event_product_bloc/event_product_bloc.dart';
import '../../blocs/event_product_bloc/event_product_event.dart';
import '../../blocs/event_product_bloc/event_product_state.dart';
import '../../blocs/spg_target_bloc/spg_target_bloc.dart';
import '../../blocs/spg_target_bloc/spg_target_event.dart';
import '../../blocs/spg_target_bloc/spg_target_state.dart';
import '../../blocs/product_bloc/product_bloc.dart';
import '../../blocs/product_bloc/product_event.dart';
import '../../blocs/product_bloc/product_state.dart';

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
    context.read<SpgTargetBloc>().add(LoadTargetsByEvent(eventId: widget.eventId));
    context.read<EventProductBloc>().add(LoadAvailableProducts(eventId: widget.eventId));
    context.read<ProductBloc>().add(LoadAllProducts());
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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('UNIT OPERATIONAL COMMAND'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded, size: 20),
          ),
          const SizedBox(width: 8),
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, spg.name),
                const SizedBox(height: 24),
                _buildSummaryDashboard(context),
                const SizedBox(height: 16),
                _buildMissionStatus(context),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Icon(Icons.inventory_2_rounded, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      'INVENTORY MANIFEST',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            fontSize: 9,
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildProductBreakdown(context),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Icon(Icons.settings_input_component_rounded, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      'OPERATIONAL SWITCHES',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            fontSize: 9,
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildActionGrid(context),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Icon(Icons.security_rounded, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      'SYSTEM PROTOCOLS',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            fontSize: 9,
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
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
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.zero,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            _getInitials(name),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.toUpperCase(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 6),
              _buildStatusIndicator(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
        return BlocBuilder<SalesBloc, SalesState>(
          builder: (context, salesState) {
            return BlocBuilder<CashBloc, CashState>(
              builder: (context, cashState) {
                bool hasData = stockState.mutations.any((m) => m.spgId == widget.spgId);
                bool isMatch = false;

                if (hasData) {
                  final spgSales = salesState.allSales.where((s) => s.spgId == widget.spgId);
                  final totalTerjual = spgSales.fold(0, (sum, s) => sum + s.qtySold);
                  isMatch = totalTerjual >= 0; 
                }

                final label = !hasData ? "NO DATA LOGGED" : (isMatch ? "ACTIVE OPERATIONS" : "REVIEW REQUIRED");
                final color = !hasData ? AppColors.onSurfaceVariant : (isMatch ? AppColors.success : AppColors.warning);

                return Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.zero),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: 1.0,
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

  Widget _buildMissionStatus(BuildContext context) {
    return BlocBuilder<SpgTargetBloc, SpgTargetState>(
      builder: (context, targetState) {
        if (targetState is! SpgTargetsLoaded) {
          return const SizedBox.shrink();
        }
        return BlocBuilder<SalesBloc, SalesState>(
          builder: (context, salesState) {
            final targets = targetState.targets.where((t) => t.spgId == widget.spgId).toList();
            final sales = salesState.allSales.where((s) => s.spgId == widget.spgId).toList();

            if (targets.isEmpty) return const SizedBox.shrink();

            final totalTarget = targets.fold(0, (sum, t) => sum + t.targetQty);
            final totalSold = sales.fold(0, (sum, s) => sum + s.qtySold);
            final percentage = totalTarget > 0 ? (totalSold / totalTarget) * 100 : 0.0;
            final color = percentage < 50 ? AppColors.error : (percentage < 80 ? AppColors.warning : AppColors.success);

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.zero,
                border: Border.all(color: AppColors.surfaceContainerHigh),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.track_changes_rounded, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        'OBJECTIVE PROGRESS',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              letterSpacing: 1.5,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${percentage.toInt()}%',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color, letterSpacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (percentage / 100).clamp(0.0, 1.0),
                      child: Container(color: color),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _miniLabel(context, 'CURRENT: $totalSold'),
                      _miniLabel(context, 'QUOTA: $totalTarget'),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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

  Widget _buildSummaryDashboard(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
        return BlocBuilder<SalesBloc, SalesState>(
          builder: (context, salesState) {
            return BlocBuilder<CashBloc, CashState>(
              builder: (context, cashState) {
                final spgMutations = stockState.mutations.where((m) => m.spgId == widget.spgId).toList();
                final spgSales = salesState.allSales.where((s) => s.spgId == widget.spgId).toList();
                final spgCash = cashState.allCash.where((c) => c.spgId == widget.spgId).firstOrNull;

                final totalGiven = spgMutations.where((m) => m.type != MutationType.returnMutation).fold(0, (sum, m) => sum + m.qty);
                final totalReturn = spgMutations.where((m) => m.type == MutationType.returnMutation).fold(0, (sum, m) => sum + m.qty);
                final totalSold = spgSales.fold(0, (sum, s) => sum + s.qtySold);
                final stockInHand = totalGiven - totalReturn - totalSold;
                final totalCash = (spgCash?.cashReceived ?? 0) + (spgCash?.qrisReceived ?? 0);

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.zero,
                    border: Border.all(color: AppColors.surfaceContainerHigh),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLargeStat('DISTRIBUTED', totalGiven, AppColors.success),
                          _buildLargeStat('SOLD', totalSold, AppColors.secondary),
                          _buildLargeStat('REMAINING', stockInHand, AppColors.onSurface),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(height: 1, color: AppColors.surfaceContainerHigh),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 18),
                          const SizedBox(width: 12),
                          Text(
                            'AGGREGATE CASH SETTLEMENT',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9,
                                  letterSpacing: 1.5,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            app_formatters.Formatters.formatCurrency(totalCash),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.primary,
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

  Widget _buildLargeStat(String label, dynamic value, Color color) {
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
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProductBreakdown(BuildContext context) {
    return BlocBuilder<EventProductBloc, EventProductState>(
      builder: (context, epState) {
        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, productState) {
            return BlocBuilder<StockBloc, StockState>(
              builder: (context, stockState) {
                return BlocBuilder<SalesBloc, SalesState>(
                  builder: (context, salesState) {
                    return BlocBuilder<SpgTargetBloc, SpgTargetState>(
                      builder: (context, targetState) {
                        if (epState is! AvailableProductsLoaded || productState is! ProductsLoaded) {
                          return const SizedBox.shrink();
                        }

                    final assignedProducts = epState.assignedProducts;
                    if (assignedProducts.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...assignedProducts.map((ep) {
                          final product = productState.products
                              .firstWhereOrNull((p) => p.id == ep.productId);
                          if (product == null) return const SizedBox.shrink();

                          final mutations = stockState.mutations
                              .where(
                                (m) =>
                                    m.spgId == widget.spgId &&
                                    m.productId == ep.productId,
                              )
                              .toList();

                          final given = mutations
                              .where(
                                (m) =>
                                    m.type == MutationType.initial ||
                                    m.type == MutationType.topup,
                              )
                              .fold(0, (sum, m) => sum + m.qty);

                          final returned = mutations
                              .where(
                                (m) => m.type == MutationType.returnMutation,
                              )
                              .fold(0, (sum, m) => sum + m.qty);

                          final sales = salesState.allSales
                              .where(
                                (s) =>
                                    s.spgId == widget.spgId &&
                                    s.productId == ep.productId,
                              )
                              .firstOrNull;

                          final sold = sales?.qtySold ?? 0;
                          final remaining = given - returned - sold;

                          int target = 0;
                          if (targetState is SpgTargetsLoaded) {
                            target = targetState.targets.firstWhereOrNull((t) => t.productId == ep.productId && t.spgId == widget.spgId)?.targetQty ?? 0;
                          }

                          return _buildProductCard(
                            context,
                            product: product,
                            given: given,
                            returned: returned,
                            sold: sold,
                            remaining: remaining,
                            target: target,
                            price: ep.price,
                          );
                        }),
                      ],
                    );
                      },
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

  Widget _buildProductCard(
    BuildContext context, {
    required dynamic product,
    required int given,
    required int returned,
    required int sold,
    required int remaining,
    required int target,
    required double price,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                ),
              ),
              Text(
                app_formatters.Formatters.formatCurrency(price),
                style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.secondary, fontSize: 13),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.surfaceContainerHigh),
          ),
          Row(
            children: [
              _buildMiniStat('TGT', target, AppColors.onSurfaceVariant),
              _buildMiniStat('DIST', given, AppColors.success),
              _buildMiniStat('RET', returned, AppColors.warning),
              _buildMiniStat('SOLD', sold, AppColors.secondary),
              _buildMiniStat('STOCK', remaining, AppColors.onSurface),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, dynamic value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant, letterSpacing: 1.0),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
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
          label: 'RESUPPLY_SYNC',
          color: AppColors.success,
          route: 'topup',
        ),
        _buildGridButton(
          context,
          icon: Icons.refresh,
          label: 'RECOVERY_LINK',
          color: AppColors.warning,
          route: 'return',
        ),
        _buildGridButton(
          context,
          icon: Icons.bar_chart,
          label: 'REVENUE_CAPTURE',
          color: AppColors.secondary,
          route: 'sales_input',
        ),
        _buildGridButton(
          context,
          icon: Icons.account_balance_wallet_outlined,
          label: 'CREDIT_SETTLEMENT',
          color: AppColors.primary,
          route: 'cash_input',
        ),
      ],
    );
  }

  Widget _buildSetupAction(BuildContext context) {
    return Column(
      children: [
        _buildListButton(
          context,
          icon: Icons.app_registration,
          label: 'INITIAL_ALLOCATION',
          subtitle: 'EXECUTE PRIMARY ASSET DISTRIBUTION',
          color: AppColors.primary,
          route: 'initial_distribution',
        ),
        const SizedBox(height: 12),
        _buildListButton(
          context,
          icon: Icons.history_outlined,
          label: 'LOGISTICS_HISTORY',
          subtitle: 'AUDIT & VERIFY MUTATION RECORDS',
          color: AppColors.secondary,
          route: 'stock_history_spg',
        ),
      ],
    );
  }

  Widget _buildGridButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required String route,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.pushNamed(
            route,
            pathParameters: {'eventId': widget.eventId, 'spgId': widget.spgId},
          ),
          borderRadius: BorderRadius.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: ListTile(
        onTap: () => context.pushNamed(
          route,
          pathParameters: {'eventId': widget.eventId, 'spgId': widget.spgId},
        ),
        dense: true,
        leading: Icon(icon, color: color, size: 18),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          label.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5),
        ),
        subtitle: Text(
          subtitle.toUpperCase(),
          style: TextStyle(fontSize: 8, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
      ),
    );
  }

  Widget _buildClosingButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.pushNamed(
          'spg_closing',
          pathParameters: {'eventId': widget.eventId, 'spgId': widget.spgId},
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceContainerHigh,
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          elevation: 0,
          side: const BorderSide(color: AppColors.primary, width: 1),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_reset_rounded, size: 18),
            SizedBox(width: 12),
            Text(
              'EXECUTE CLOSING PROTOCOL',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
