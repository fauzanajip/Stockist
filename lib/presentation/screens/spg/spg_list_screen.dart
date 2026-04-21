import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart' as app_formatters;
import '../../../domain/entities/event_spg_entity.dart';
import '../../../domain/entities/spg_entity.dart';
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

class SpgListScreen extends StatelessWidget {
  final String eventId;

  const SpgListScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventSpgBloc, EventSpgState>(
      listener: (context, state) {
        if (state is! EventSpgLoading && 
            state is! AvailableSpgsLoaded && 
            state is! AssignedSpgsLoaded) {
          context.read<EventSpgBloc>().add(LoadAvailableSpgs(eventId: eventId));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SPG List'),
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
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<EventSpgBloc>().add(LoadAvailableSpgs(eventId: eventId)),
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
              return _buildSpgList(context, state.assignedSpgs);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 64, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'Belum ada SPG di event ini',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Setup SPG di Event Setup terlebih dahulu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpgList(BuildContext context, List<EventSpgEntity> eventSpgs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: eventSpgs.length,
      itemBuilder: (context, index) {
        return SpgDashboardCard(eventId: eventId, eventSpg: eventSpgs[index]);
      },
    );
  }
}

class SpgDashboardCard extends StatelessWidget {
  final String eventId;
  final EventSpgEntity eventSpg;

  const SpgDashboardCard({
    super.key,
    required this.eventId,
    required this.eventSpg,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpgBloc, SpgState>(
      builder: (context, spgState) {
        if (spgState is! SpqsLoaded) {
          return const Card(child: ListTile(title: Text('Loading SPG...')));
        }
        
        final spg = spgState.spqs.firstWhere((s) => s.id == eventSpg.spgId);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => context.pushNamed(
              'spg_detail',
              pathParameters: {
                'eventId': eventId,
                'spgId': spg.id,
              },
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          spg.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildStatusIndicator(context, eventId, spg.id),
                    ],
                  ),
                  if (eventSpg.spbId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'SPB: ${eventSpg.spbId}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _SpgDashboardStats(eventId: eventId, spgId: spg.id),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(BuildContext context, String eventId, String spgId) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
        return BlocBuilder<SalesBloc, SalesState>(
          builder: (context, salesState) {
            return BlocBuilder<CashBloc, CashState>(
              builder: (context, cashState) {
                bool hasData = stockState.mutations.isNotEmpty && 
                              salesState.salesByProduct.isNotEmpty;
                bool isMatch = false;
                
                if (hasData) {
                  final totalGiven = stockState.totalGiven;
                  final totalTerjual = salesState.salesByProduct.values.fold(0, (sum, val) => sum + val);
                  final cashTotal = cashState.cashReceived + cashState.qrisReceived;
                  
                  if (totalTerjual > 0) {
                    final expectedCash = totalTerjual * 10000;
                    final surplus = cashTotal - expectedCash;
                    isMatch = surplus == 0;
                  } else {
                    isMatch = cashTotal == 0;
                  }
                }
                
                if (!hasData) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.onSurface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '⏳',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isMatch ? AppColors.primary : AppColors.warning,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isMatch ? '✅' : '⚠️',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
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
}

class _SpgDashboardStats extends StatefulWidget {
  final String eventId;
  final String spgId;

  const _SpgDashboardStats({
    required this.eventId,
    required this.spgId,
  });

  @override
  State<_SpgDashboardStats> createState() => _SpgDashboardStatsState();
}

class _SpgDashboardStatsState extends State<_SpgDashboardStats> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<StockBloc>().add(LoadStockByEventSpg(
      eventId: widget.eventId,
      spgId: widget.spgId,
    ));
    context.read<SalesBloc>().add(LoadSales(
      eventId: widget.eventId,
      spgId: widget.spgId,
    ));
    context.read<CashBloc>().add(LoadCashRecord(
      eventId: widget.eventId,
      spgId: widget.spgId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
        return BlocBuilder<SalesBloc, SalesState>(
          builder: (context, salesState) {
            return BlocBuilder<CashBloc, CashState>(
              builder: (context, cashState) {
                final initialQty = stockState.mutations
                    .where((m) => m.type == MutationType.initial)
                    .fold(0, (sum, m) => sum + m.qty);
                final topupQty = stockState.mutations
                    .where((m) => m.type == MutationType.topup)
                    .fold(0, (sum, m) => sum + m.qty);
                final returnQty = stockState.mutations
                    .where((m) => m.type == MutationType.returnMutation)
                    .fold(0, (sum, m) => sum + m.qty);
                
                final totalGiven = StockCalculator.calculateTotalGiven(
                  initialQty: initialQty,
                  topupQty: topupQty,
                );
                final totalReturn = StockCalculator.calculateTotalReturn(
                  returnQty: returnQty,
                );
                final totalTerjual = salesState.salesByProduct.values.fold(0, (sum, val) => sum + val);
                final sisaSystem = StockCalculator.calculateSisaSystem(
                  totalDikasih: totalGiven,
                  totalReturn: totalReturn,
                  totalTerjual: totalTerjual,
                );
                
                final cashReceived = cashState.cashReceived;
                final qrisReceived = cashState.qrisReceived;
                final totalCash = cashReceived + qrisReceived;

                return Column(
                  children: [
                    Row(
                      children: [
                        _buildStatItem('Dikasih', totalGiven.toString(), AppColors.primary),
                        const SizedBox(width: 16),
                        _buildStatItem('Terjual', totalTerjual.toString(), AppColors.secondary),
                        const SizedBox(width: 16),
                        _buildStatItem('Sisa', sisaSystem.toString(), AppColors.onSurface),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildCashStatItem('Cash', app_formatters.Formatters.formatCurrency(totalCash)),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashStatItem(String label, String value) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}
