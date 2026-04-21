import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stockist/core/utils/formatters.dart' as app_formatters;
import 'package:stockist/domain/entities/stock_mutation_entity.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/excel_export_service.dart';
import '../../blocs/event_bloc/event_bloc.dart';
import '../../blocs/event_bloc/event_event.dart';
import '../../blocs/event_bloc/event_state.dart';
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
import '../../blocs/spg_bloc/spg_event.dart';
import '../../blocs/spg_bloc/spg_state.dart';
import '../../blocs/product_bloc/product_bloc.dart';
import '../../blocs/product_bloc/product_event.dart';
import '../../blocs/product_bloc/product_state.dart';
import '../../blocs/event_spg_bloc/event_spg_bloc.dart';
import '../../blocs/event_spg_bloc/event_spg_event.dart';
import '../../blocs/event_spg_bloc/event_spg_state.dart';
import '../../blocs/event_product_bloc/event_product_bloc.dart';
import '../../blocs/event_product_bloc/event_product_event.dart';
import '../../blocs/event_product_bloc/event_product_state.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<EventBloc>().add(LoadEventById(id: widget.eventId));
    context.read<StockBloc>().add(LoadStockByEvent(eventId: widget.eventId));
    context.read<SalesBloc>().add(LoadAllSalesByEvent(eventId: widget.eventId));
    context.read<CashBloc>().add(LoadAllCashByEvent(eventId: widget.eventId));

    // Load data for export
    context.read<SpgBloc>().add(LoadAllSpqs());
    context.read<ProductBloc>().add(LoadAllProducts());
    context.read<EventSpgBloc>().add(LoadAvailableSpgs(eventId: widget.eventId));
    context
        .read<EventProductBloc>()
        .add(LoadAvailableProducts(eventId: widget.eventId));
  }

  Future<void> _exportData() async {
    final eventState = context.read<EventBloc>().state;
    if (eventState is! EventDetailLoaded) return;

    final stockState = context.read<StockBloc>().state;
    final salesState = context.read<SalesBloc>().state;
    final cashState = context.read<CashBloc>().state;
    final spgState = context.read<SpgBloc>().state;
    final productState = context.read<ProductBloc>().state;
    final eventSpgState = context.read<EventSpgBloc>().state;
    final eventProductState = context.read<EventProductBloc>().state;

    if (spgState is! SpqsLoaded ||
        productState is! ProductsLoaded ||
        eventSpgState is! AvailableSpgsLoaded ||
        eventProductState is! AvailableProductsLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tunggu sebentar, sedang menyiapkan data...'),
        ),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menyiapkan Laporan Excel...')),
      );

      final filePath = await ExcelExportService.exportEvent(
        event: eventState.event,
        eventSpgs: eventSpgState.assignedSpgs,
        spgs: spgState.spqs,
        eventProducts: eventProductState.assignedProducts,
        products: productState.products,
        stockMutations: stockState.mutations,
        sales: salesState.allSales,
        cashRecords: cashState.allCash,
      );

      await ExcelExportService.shareExcel(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengekspor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Detail'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushNamed(
              'event_setup',
              pathParameters: {'eventId': widget.eventId},
            ),
          ),
        ],
      ),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, eventState) {
          if (eventState is EventLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (eventState is EventDetailLoaded) {
            final event = eventState.event;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, event.name, event.date),
                  const SizedBox(height: 24),
                  _buildEventDashboard(context),
                  const SizedBox(height: 32),
                  _buildProductBreakdown(context),
                  const SizedBox(height: 32),
                  _buildActionSection(context),
                ],
              ),
            );
          }

          if (eventState is EventError) {
            return Center(child: Text('Error: ${eventState.message}'));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: const Text(
                'ACTIVE',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
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
              app_formatters.Formatters.formatDate(date),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventDashboard(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
        return BlocBuilder<SalesBloc, SalesState>(
          builder: (context, salesState) {
            return BlocBuilder<CashBloc, CashState>(
              builder: (context, cashState) {
                final totalFromDistributor = stockState.mutations
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

                final stockInWarehouse =
                    totalFromDistributor - totalDistributed + totalReturn;

                final totalSold = salesState.allSales.fold(
                  0,
                  (sum, s) => sum + s.qtySold,
                );
                final totalCash = cashState.allCash.fold(
                  0.0,
                  (sum, c) => sum + c.actualCash,
                );

                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatColumn(
                            'WAREHOUSE',
                            stockInWarehouse.toString(),
                            AppColors.primary,
                          ),
                          _buildStatColumn(
                            'DISTRIBUTED',
                            totalDistributed.toString(),
                            AppColors.success,
                          ),
                          _buildStatColumn(
                            'SOLD',
                            totalSold.toString(),
                            AppColors.secondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 24),
                      Row(
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
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                app_formatters.Formatters.formatCurrency(
                                  totalCash,
                                ),
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.payments_outlined,
                              color: AppColors.secondary,
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

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MANAGEMENT',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          context,
          icon: Icons.people_outline,
          title: 'Manage SPG',
          subtitle: 'Lihat daftar SPG dan performa individu',
          color: AppColors.primary,
          onTap: () => context.pushNamed(
            'spg_list',
            pathParameters: {'eventId': widget.eventId},
          ),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          context,
          icon: Icons.file_download_outlined,
          title: 'Export Excel',
          subtitle: 'Download laporan lengkap event (XLSX)',
          color: AppColors.success,
          onTap: _exportData,
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          context,
          icon: Icons.settings_outlined,
          title: 'Event Settings',
          subtitle: 'Ubah produk dan petugas SPG',
          color: AppColors.onSurfaceVariant,
          onTap: () => context.pushNamed(
            'event_setup',
            pathParameters: {'eventId': widget.eventId},
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductBreakdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'PRODUCT BREAKDOWN',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<EventProductBloc, EventProductState>(
          builder: (context, epState) {
            if (epState is! AvailableProductsLoaded) {
              return const SizedBox.shrink();
            }

            return BlocBuilder<StockBloc, StockState>(
              builder: (context, stockState) {
                return BlocBuilder<SalesBloc, SalesState>(
                  builder: (context, salesState) {
                    final assignedProducts = epState.assignedProducts;
                    if (assignedProducts.isEmpty) {
                      return Text(
                        'Belum ada produk yang disetup.',
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }

                    return Column(
                      children:
                          assignedProducts.map((ep) {
                            final product = epState.products.firstWhere(
                              (p) => p.id == ep.productId,
                            );

                            final totalIn = stockState.mutations
                                .where(
                                  (m) =>
                                      m.productId == ep.productId &&
                                      m.type == MutationType.distributorToEvent,
                                )
                                .fold(0, (sum, m) => sum + m.qty);

                            final totalDistributed = stockState.mutations
                                .where(
                                  (m) =>
                                      m.productId == ep.productId &&
                                      m.spgId != 'WAREHOUSE' &&
                                      (m.type == MutationType.initial ||
                                          m.type == MutationType.topup),
                                )
                                .fold(0, (sum, m) => sum + m.qty);

                            final totalReturn = stockState.mutations
                                .where(
                                  (m) =>
                                      m.productId == ep.productId &&
                                      m.type == MutationType.returnMutation,
                                )
                                .fold(0, (sum, m) => sum + m.qty);

                            final totalSold = salesState.allSales
                                .where((s) => s.productId == ep.productId)
                                .fold(0, (sum, s) => sum + s.qtySold);

                            final warehouseStock =
                                totalIn - totalDistributed + totalReturn;
                            final totalRemaining = totalIn - totalSold;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'SKU: ${product.sku}',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildMiniStat(
                                        'WAREHOUSE',
                                        warehouseStock.toString(),
                                        AppColors.primary,
                                      ),
                                      _buildMiniStat(
                                        'DISTRIBUTED',
                                        totalDistributed.toString(),
                                        AppColors.success,
                                      ),
                                      _buildMiniStat(
                                        'SOLD',
                                        totalSold.toString(),
                                        AppColors.secondary,
                                      ),
                                      _buildMiniStat(
                                        'TOTAL SISA',
                                        totalRemaining.toString(),
                                        AppColors.onSurface,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}
