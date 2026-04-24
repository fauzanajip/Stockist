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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MISSION: DEBRIEFING',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
            ),
            const Text(
              'PROTOCOL TERMINAL AUDIT',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: -0.5),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'SYNC_TELEMETRY'.toUpperCase(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.surfaceContainerHigh, height: 1),
        ),
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
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                          }

                          if (productState is! AvailableProductsLoaded) {
                            return _buildEmptyState();
                          }

                          final hasAllSalesData = productState.assignedProducts.every(
                            (p) => salesState.salesByProduct.containsKey(p.productId),
                          );
                          final hasCashData = cashState.actualCash > 0;
                          final canClose = hasAllSalesData && hasCashData;

                          double expectedCash = 0;
                          int totalSelisihFisik = 0;
                          for (final ap in productState.assignedProducts) {
                            final pid = ap.productId;
                            final mutations = stockState.mutations.where((m) => m.productId == pid).toList();
                            final totalGiven = mutations.where((m) => m.type != MutationType.returnMutation).fold(0, (sum, m) => sum + m.qty);
                            final totalReturned = mutations.where((m) => m.type == MutationType.returnMutation).fold(0, (sum, m) => sum + m.qty);
                            final totalSold = salesState.salesByProduct[pid] ?? 0;
                            final sisaSystem = totalGiven - totalReturned - totalSold;
                            final sisaRealValue = _sisaReal[pid] ?? sisaSystem;

                            expectedCash += totalSold * ap.price;
                            totalSelisihFisik += StockCalculator.calculateSelisihFisik(
                              sisaSystem: sisaSystem,
                              sisaReal: sisaRealValue,
                            );
                          }

                          final surplus = StockCalculator.calculateSurplus(actualCash: cashState.actualCash, expectedCash: expectedCash);
                          final status = StockCalculator.determineClosingStatus(
                            selisihFisik: totalSelisihFisik,
                            surplus: surplus,
                            hasAllSalesData: hasAllSalesData,
                            hasCashData: hasCashData,
                          );

                          return BlocBuilder<SpgTargetBloc, SpgTargetState>(
                            builder: (context, targetState) {
                              return Column(
                                children: [
                                  _buildHeader(context, spgName),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          _buildProductTable(
                                            context,
                                            productState,
                                            stockState,
                                            salesState,
                                            targetState,
                                          ),
                                          _buildSummarySection(
                                            context,
                                            productState,
                                            salesState,
                                            cashState,
                                            surplus,
                                            expectedCash,
                                          ),
                                          _buildStatusIndicator(context, status, totalSelisihFisik),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _buildBottomAction(canClose),
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
    );
  }

  Widget _buildHeader(BuildContext context, String spgName) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceContainerLowest,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEBRIEFING_TARGET_UNIT'.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            spgName.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'SYSTEM TELEMETRY AUDIT. VERIFY ASSET CONSUMPTION VS REVENUE CAPTURE. NO DISCREPANCIES ALLOWED FOR AUTOMATIC ARCHIVAL.'.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
              fontWeight: FontWeight.bold,
            ),
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
    final targets = targetState is SpgTargetsLoaded ? targetState.targets : <SpgProductTargetEntity>[];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.surfaceContainerHigh),
        ),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: FixedColumnWidth(180),
            1: FixedColumnWidth(70),
            2: FixedColumnWidth(70),
            3: FixedColumnWidth(70),
            4: FixedColumnWidth(70),
            5: FixedColumnWidth(80),
            6: FixedColumnWidth(80),
            7: FixedColumnWidth(90),
            8: FixedColumnWidth(80),
          },
          children: [
            _buildTableHeader(context),
            ...productState.assignedProducts.map((assignedProduct) {
              final product = productState.products.firstWhere((p) => p.id == assignedProduct.productId);
              final mutations = stockState.mutations.where((m) => m.productId == product.id).toList();
              final totalGiven = mutations.where((m) => m.type != MutationType.returnMutation).fold(0, (sum, m) => sum + m.qty);
              final totalReturned = mutations.where((m) => m.type == MutationType.returnMutation).fold(0, (sum, m) => sum + m.qty);
              final totalSold = salesState.salesByProduct[product.id] ?? 0;
              final sisaSystem = totalGiven - totalReturned - totalSold;
              final sisaRealValue = _sisaReal[product.id] ?? sisaSystem;
              final selisihFisik = StockCalculator.calculateSelisihFisik(sisaSystem: sisaSystem, sisaReal: sisaRealValue);
              final productTarget = targets.where((t) => t.productId == product.id).fold(0, (sum, t) => sum + t.targetQty);
              final progressPercent = productTarget > 0 ? (totalSold / productTarget * 100).clamp(0.0, 999.0) : 0.0;

              return TableRow(
                decoration: BoxDecoration(
                  color: selisihFisik != 0 ? AppColors.error.withOpacity(0.05) : null,
                  border: const Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
                ),
                children: [
                  _buildTableCell(context, product.name.toUpperCase(), isBold: true, textAlign: TextAlign.left),
                  _buildTableCell(context, totalGiven.toString()),
                  _buildTableCell(context, totalReturned.toString()),
                  _buildTableCell(context, totalSold.toString()),
                  _buildTableCell(context, productTarget.toString()),
                  _buildProgressCell(context, progressPercent),
                  _buildTableCell(context, sisaSystem.toString(), color: AppColors.secondary),
                  _buildSisaRealCell(context, product.id, sisaRealValue),
                  _buildTableCell(
                    context,
                    selisihFisik.toString(),
                    color: selisihFisik != 0 ? AppColors.error : AppColors.success,
                    isBold: true,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableHeader(BuildContext context) {
    return TableRow(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh, width: 2)),
      ),
      children: [
        _buildHeaderCell(context, 'ASSET_NAME'),
        _buildHeaderCell(context, 'GIVEN'),
        _buildHeaderCell(context, 'RET'),
        _buildHeaderCell(context, 'SOLD'),
        _buildHeaderCell(context, 'TGT'),
        _buildHeaderCell(context, 'PROG'),
        _buildHeaderCell(context, 'SYS_STOCK'),
        _buildHeaderCell(context, 'PHYS_STOCK'),
        _buildHeaderCell(context, 'DELTA'),
      ],
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant, letterSpacing: 1),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(
    BuildContext context,
    String text, {
    bool isBold = false,
    Color? color,
    TextAlign textAlign = TextAlign.center,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
          color: color,
        ),
        textAlign: textAlign,
      ),
    );
  }

  Widget _buildProgressCell(BuildContext context, double percent) {
    final displayPercent = percent > 999 ? '999+' : '${percent.toInt()}%';
    final color = percent < 50 ? AppColors.error : percent < 80 ? AppColors.warning : AppColors.success;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(0.1), border: Border.all(color: color.withOpacity(0.5))),
        child: Text(
          displayPercent,
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSisaRealCell(BuildContext context, String productId, int value) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: 32,
        child: TextField(
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.primary),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.surfaceContainerHigh)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.surfaceContainerHigh)),
          ),
          controller: TextEditingController(text: value.toString()),
          onChanged: (val) {
            final newValue = int.tryParse(val) ?? 0;
            setState(() {
              _sisaReal[productId] = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    AvailableProductsLoaded productState,
    SalesState salesState,
    CashState cashState,
    double surplus,
    double expectedCash,
  ) {
    final actualCash = cashState.actualCash;

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Column(
        children: [
          _buildAuditRow('EXPECTED_REVENUE'.toUpperCase(), expectedCash, AppColors.secondary),
          const SizedBox(height: 12),
          _buildAuditRow('ACTUAL_SETTLEMENT'.toUpperCase(), actualCash, AppColors.primary),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 1, color: AppColors.surfaceContainerHigh),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FINAL_AUDIT_DELTA'.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
              ),
              Text(
                surplus == 0
                    ? 'RP 0'
                    : (surplus > 0
                        ? '+ ${app_formatters.Formatters.formatCurrency(surplus)}'
                        : '- ${app_formatters.Formatters.formatCurrency(surplus.abs())}'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: surplus == 0 ? AppColors.success : (surplus > 0 ? AppColors.success : AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuditRow(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppColors.onSurfaceVariant)),
        Text(
          app_formatters.Formatters.formatCurrency(value).toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(BuildContext context, String status, int totalSelisihFisik) {
    final color = status == '✅' ? AppColors.success : AppColors.error;
    final label = totalSelisihFisik == 0 && status == '✅' ? 'MISSION_INTEGRITY: VERIFIED' : 'MISSION_INTEGRITY: DISCREPANCY_DETECTED';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(status == '✅' ? Icons.verified_user_rounded : Icons.warning_amber_rounded, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, color: color, letterSpacing: 1.5, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('NO MISSION ASSETS FOUND'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            child: const Text('ABORT DEBRIEFING'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(bool canClose) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: canClose
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('MISSION_TERMINATED: ARCHIVING DATA...'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      // borderRadius: BorderRadius.zero,
                    ),
                  );
                  context.pop();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
          ),
          child: Text(
            canClose ? 'TERMINATE MISSION & ARCHIVE DATA' : 'AUDIT_INCOMPLETE: ACTION_BLOCKED',
            style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _miniLabel(BuildContext context, String text) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
    );
  }
}
