import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart' as app_formatters;
import '../../../core/utils/stock_calculator.dart';
import '../../../domain/entities/stock_mutation_entity.dart';
import '../../../domain/entities/spg_product_target_entity.dart';
import '../../blocs/event_product_bloc/event_product_bloc.dart';
import '../../blocs/event_product_bloc/event_product_event.dart';
import '../../blocs/event_product_bloc/event_product_state.dart';
import '../../blocs/sales_bloc/sales_bloc.dart';
import '../../blocs/sales_bloc/sales_event.dart';
import '../../blocs/sales_bloc/sales_state.dart';
import '../../blocs/cash_bloc/cash_bloc.dart';
import '../../blocs/cash_bloc/cash_event.dart';
import '../../blocs/cash_bloc/cash_state.dart';
import '../../blocs/spg_bloc/spg_bloc.dart';
import '../../blocs/spg_bloc/spg_event.dart';
import '../../blocs/spg_bloc/spg_state.dart';
import '../../blocs/stock_bloc/stock_bloc.dart';
import '../../blocs/stock_bloc/stock_event.dart';
import '../../blocs/stock_bloc/stock_state.dart';
import '../../blocs/spg_target_bloc/spg_target_bloc.dart';
import '../../blocs/spg_target_bloc/spg_target_event.dart';
import '../../blocs/spg_target_bloc/spg_target_state.dart';

class SpgClosingScreen extends StatefulWidget {
  final String eventId;
  final String spgId;

  const SpgClosingScreen({
    super.key,
    required this.eventId,
    required this.spgId,
  });

  @override
  State<SpgClosingScreen> createState() => _SpgClosingScreenState();
}

class _SpgClosingScreenState extends State<SpgClosingScreen> {
  final Map<String, int> _sisaReal = {};
  bool _canClose = false;
  String _status = '⚠️';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<SpgBloc>().add(LoadAllSpqs());
    context.read<EventProductBloc>().add(
      LoadAvailableProducts(eventId: widget.eventId),
    );
    context.read<StockBloc>().add(
      LoadStockByEventSpg(eventId: widget.eventId, spgId: widget.spgId),
    );
    context.read<SalesBloc>().add(
      LoadSales(eventId: widget.eventId, spgId: widget.spgId),
    );
    context.read<CashBloc>().add(
      LoadCashRecord(eventId: widget.eventId, spgId: widget.spgId),
    );
    context.read<SpgTargetBloc>().add(
      LoadTargetsByEventSpg(eventId: widget.eventId, spgId: widget.spgId),
    );
  }

  void _validateClosing() {
    final salesState = context.read<SalesBloc>().state;
    final cashState = context.read<CashBloc>().state;
    final productState = context.read<EventProductBloc>().state;

    bool hasAllSalesData = false;
    bool hasCashData = cashState.actualCash > 0;

    if (productState is AvailableProductsLoaded) {
      hasAllSalesData = productState.assignedProducts.every(
        (p) => salesState.salesByProduct.containsKey(p.productId),
      );
    }

    setState(() {
      _canClose = hasAllSalesData && hasCashData;
    });
  }

  void _calculateStatus() {
    final stockState = context.read<StockBloc>().state;
    final salesState = context.read<SalesBloc>().state;
    final cashState = context.read<CashBloc>().state;
    final productState = context.read<EventProductBloc>().state;

    if (productState is! AvailableProductsLoaded) return;

    double expectedCash = 0;
    int totalSelisihFisik = 0;

    for (final assignedProduct in productState.assignedProducts) {
      final productId = assignedProduct.productId;

      final mutations = stockState.mutations
          .where((m) => m.productId == productId)
          .toList();
      final totalGiven = mutations
          .where((m) => m.type != MutationType.returnMutation)
          .fold(0, (sum, m) => sum + m.qty);
      final totalReturned = mutations
          .where((m) => m.type == MutationType.returnMutation)
          .fold(0, (sum, m) => sum + m.qty);
      final totalSold = salesState.salesByProduct[productId] ?? 0;
      final sisaSystem = totalGiven - totalReturned - totalSold;
      final sisaRealValue = _sisaReal[productId] ?? sisaSystem;

      expectedCash += totalSold * assignedProduct.price;
      totalSelisihFisik += StockCalculator.calculateSelisihFisik(
        sisaSystem: sisaSystem,
        sisaReal: sisaRealValue,
      );
    }

    final actualCash = cashState.actualCash;
    final surplus = StockCalculator.calculateSurplus(
      actualCash: actualCash,
      expectedCash: expectedCash,
    );

    bool hasAllSalesData = productState.assignedProducts.every(
      (p) => salesState.salesByProduct.containsKey(p.productId),
    );
    bool hasCashData = cashState.actualCash > 0;

    setState(() {
      _status = StockCalculator.determineClosingStatus(
        selisihFisik: totalSelisihFisik,
        surplus: surplus,
        hasAllSalesData: hasAllSalesData,
        hasCashData: hasCashData,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Closing SPG'),
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: BlocBuilder<SpgBloc, SpgState>(
        builder: (context, spgState) {
          String spgName = widget.spgId;
          if (spgState is SpqsLoaded) {
            final spg = spgState.spqs.firstWhereOrNull(
              (s) => s.id == widget.spgId,
            );
            if (spg != null) spgName = spg.name;
          }

          return BlocBuilder<StockBloc, StockState>(
            builder: (context, stockState) {
              return BlocBuilder<SalesBloc, SalesState>(
                builder: (context, salesState) {
                  return BlocBuilder<CashBloc, CashState>(
                    builder: (context, cashState) {
                      return BlocBuilder<EventProductBloc, EventProductState>(
                        builder: (context, productState) {
                          if (productState is EventProductLoading ||
                              stockState.isLoading ||
                              salesState.isLoading ||
                              cashState.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (productState is! AvailableProductsLoaded) {
                            return _buildEmptyState();
                          }

                          _validateClosing();

                          return BlocBuilder<SpgTargetBloc, SpgTargetState>(
                        builder: (context, targetState) {
                          return Column(
                            children: [
                              _buildHeader(context, spgName),
                              Expanded(
                                child: _buildProductTable(
                                  context,
                                  productState,
                                  stockState,
                                  salesState,
                                  targetState,
                                ),
                              ),
                              _buildSummarySection(
                                context,
                                productState,
                                salesState,
                                cashState,
                              ),
                              _buildStatusIndicator(context),
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
        },
      ),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildHeader(BuildContext context, String spgName) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceContainer,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'CLOSING SESSION',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'SPG: $spgName',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Input sisa real per produk untuk menentukan selisih.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTable(
    BuildContext context,
    AvailableProductsLoaded productState,
    StockState stockState,
    SalesState salesState,
    SpgTargetState targetState,
  ) {
    final targets = targetState is SpgTargetsLoaded
        ? targetState.targets
        : <SpgProductTargetEntity>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Table(
        border: TableBorder.all(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FixedColumnWidth(55),
          2: FixedColumnWidth(55),
          3: FixedColumnWidth(55),
          4: FixedColumnWidth(55),
          5: FixedColumnWidth(55),
          6: FixedColumnWidth(60),
          7: FixedColumnWidth(65),
          8: FixedColumnWidth(55),
        },
        children: [
          _buildTableHeader(context),
          ...productState.assignedProducts.map((assignedProduct) {
            final product = productState.products.firstWhere(
              (p) => p.id == assignedProduct.productId,
            );

            final mutations = stockState.mutations
                .where((m) => m.productId == product.id)
                .toList();
            final totalGiven = mutations
                .where((m) => m.type != MutationType.returnMutation)
                .fold(0, (sum, m) => sum + m.qty);
            final totalReturned = mutations
                .where((m) => m.type == MutationType.returnMutation)
                .fold(0, (sum, m) => sum + m.qty);
            final totalSold = salesState.salesByProduct[product.id] ?? 0;
            final sisaSystem = totalGiven - totalReturned - totalSold;
            final sisaRealValue = _sisaReal[product.id] ?? sisaSystem;
            final selisihFisik = StockCalculator.calculateSelisihFisik(
              sisaSystem: sisaSystem,
              sisaReal: sisaRealValue,
            );

            final productTarget = targets
                .where((t) => t.productId == product.id)
                .fold(0, (sum, t) => sum + t.targetQty);
            final progressPercent = productTarget > 0
                ? (totalSold / productTarget * 100).clamp(0.0, 999.0)
                : 0.0;

            return TableRow(
              decoration: BoxDecoration(
                color: selisihFisik != 0
                    ? AppColors.warning.withOpacity(0.1)
                    : null,
              ),
              children: [
                _buildTableCell(context, product.name, isBold: true),
                _buildTableCell(context, totalGiven.toString()),
                _buildTableCell(context, totalReturned.toString()),
                _buildTableCell(context, totalSold.toString()),
                _buildTableCell(context, productTarget.toString()),
                _buildProgressCell(context, progressPercent),
                _buildTableCell(context, sisaSystem.toString()),
                _buildSisaRealCell(context, product.id, sisaRealValue),
                _buildTableCell(
                  context,
                  selisihFisik.toString(),
                  color: selisihFisik != 0
                      ? AppColors.error
                      : AppColors.success,
                  isBold: true,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  TableRow _buildTableHeader(BuildContext context) {
    return TableRow(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      children: [
        _buildHeaderCell(context, 'Produk'),
        _buildHeaderCell(context, 'Dikasih'),
        _buildHeaderCell(context, 'Return'),
        _buildHeaderCell(context, 'Terjual'),
        _buildHeaderCell(context, 'Target'),
        _buildHeaderCell(context, 'Progress'),
        _buildHeaderCell(context, 'Sisa Sys'),
        _buildHeaderCell(context, 'Sisa Real'),
        _buildHeaderCell(context, 'Selisih'),
      ],
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(
    BuildContext context,
    String text, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildProgressCell(BuildContext context, double percent) {
    final displayPercent = percent > 999 ? '999+' : '${percent.toInt()}%';
    final color = percent < 50
        ? AppColors.error
        : percent < 80
            ? AppColors.warning
            : AppColors.success;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(
          displayPercent,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSisaRealCell(BuildContext context, String productId, int value) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: TextField(
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide.none,
          ),
        ),
        controller: TextEditingController(text: value.toString()),
        onChanged: (val) {
          final newValue = int.tryParse(val) ?? 0;
          setState(() {
            _sisaReal[productId] = newValue;
          });
          _calculateStatus();
        },
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    AvailableProductsLoaded productState,
    SalesState salesState,
    CashState cashState,
  ) {
    double expectedCash = 0;

    for (final assignedProduct in productState.assignedProducts) {
      final sold = salesState.salesByProduct[assignedProduct.productId] ?? 0;
      expectedCash += sold * assignedProduct.price;
    }

    final actualCash = cashState.actualCash;
    final surplus = StockCalculator.calculateSurplus(
      actualCash: actualCash,
      expectedCash: expectedCash,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expected Cash',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                app_formatters.Formatters.formatCurrency(expectedCash),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Actual Cash (Tunai)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                app_formatters.Formatters.formatCurrency(
                  cashState.cashReceived,
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Actual Cash (QRIS)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                app_formatters.Formatters.formatCurrency(
                  cashState.qrisReceived,
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Actual',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                app_formatters.Formatters.formatCurrency(actualCash),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: surplus == 0
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Surplus/Selisih',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  surplus == 0
                      ? 'Rp 0'
                      : (surplus > 0
                            ? '+ ${app_formatters.Formatters.formatCurrency(surplus)}'
                            : '- ${app_formatters.Formatters.formatCurrency(surplus.abs())}'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: surplus == 0
                        ? AppColors.success
                        : (surplus > 0 ? AppColors.success : AppColors.error),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    _calculateStatus();

    final stockState = context.read<StockBloc>().state;
    final salesState = context.read<SalesBloc>().state;
    final productState = context.read<EventProductBloc>().state;

    int totalSelisihFisik = 0;

    if (productState is AvailableProductsLoaded) {
      for (final assignedProduct in productState.assignedProducts) {
        final productId = assignedProduct.productId;
        final mutations = stockState.mutations
            .where((m) => m.productId == productId)
            .toList();
        final totalGiven = mutations
            .where((m) => m.type != MutationType.returnMutation)
            .fold(0, (sum, m) => sum + m.qty);
        final totalReturned = mutations
            .where((m) => m.type == MutationType.returnMutation)
            .fold(0, (sum, m) => sum + m.qty);
        final totalSold = salesState.salesByProduct[productId] ?? 0;
        final sisaSystem = totalGiven - totalReturned - totalSold;
        final sisaRealValue = _sisaReal[productId] ?? sisaSystem;

        totalSelisihFisik += StockCalculator.calculateSelisihFisik(
          sisaSystem: sisaSystem,
          sisaReal: sisaRealValue,
        );
      }
    }

    final color = _status == '✅' ? AppColors.success : AppColors.warning;
    final label = totalSelisihFisik == 0 && _status == '✅'
        ? 'SEMPURNA - Tidak ada selisih'
        : 'PERLU REVIEW - Ada selisih stok/cash';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color.withOpacity(0.1),
      child: Row(
        children: [
          Text(_status, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
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
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          const Text('Belum ada produk yang di-assign ke event ini'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Ke Event Setup'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_canClose)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Closing belum bisa dilakukan. Pastikan semua produk sudah ada data sales dan cash sudah diinput.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed: _canClose
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Closing berhasil! Data SPG sudah valid.',
                          ),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      context.pop();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canClose
                    ? AppColors.success
                    : AppColors.surfaceContainerHigh,
                foregroundColor: _canClose
                    ? Colors.white
                    : AppColors.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_canClose ? Icons.check_circle : Icons.lock_outline),
                  const SizedBox(width: 8),
                  Text(
                    _canClose ? 'SELESAI CLOSING' : 'CLOSING BELUM LENGKAP',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
