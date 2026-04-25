import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/excel_import_service.dart';
import '../../../domain/usecases/sales_usecases.dart';
import '../../../domain/usecases/cash_record_usecases.dart';
import '../../blocs/sales_bloc/sales_bloc.dart';
import '../../blocs/sales_bloc/sales_event.dart';
import '../../blocs/sales_bloc/sales_state.dart';
import '../../blocs/cash_bloc/cash_bloc.dart';
import '../../blocs/cash_bloc/cash_event.dart';
import '../../blocs/cash_bloc/cash_state.dart';
import '../../blocs/event_spg_bloc/event_spg_bloc.dart';
import '../../blocs/event_spg_bloc/event_spg_event.dart';
import '../../blocs/event_spg_bloc/event_spg_state.dart';
import '../../blocs/event_product_bloc/event_product_bloc.dart';
import '../../blocs/event_product_bloc/event_product_event.dart';
import '../../blocs/event_product_bloc/event_product_state.dart';

class ImportSalesPreviewScreen extends StatefulWidget {
  final String eventId;
  final TransactionImportResult importResult;

  const ImportSalesPreviewScreen({
    super.key,
    required this.eventId,
    required this.importResult,
  });

  @override
  State<ImportSalesPreviewScreen> createState() => _ImportSalesPreviewScreenState();
}

class _ImportSalesPreviewScreenState extends State<ImportSalesPreviewScreen> {
  final Map<String, String> _spgMappings = {};
  final Map<String, String> _productMappings = {};
  bool _isSaving = false;
  bool _hasAutoMatched = false;
  bool _isCashSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<EventSpgBloc>().add(LoadAvailableSpgs(eventId: widget.eventId));
    context.read<EventProductBloc>().add(LoadAvailableProducts(eventId: widget.eventId));
  }

  void _autoMatch(AvailableSpgsLoaded spgState, AvailableProductsLoaded productState) {
    if (_hasAutoMatched) return;
    
    bool anyMatched = false;
    
    for (final item in widget.importResult.salesItems) {
      final matchedSpg = spgState.spgs.firstWhereOrNull(
        (s) => s.name.trim().toUpperCase() == item.spgName,
      );
      if (matchedSpg != null) {
        _spgMappings[item.spgName] = matchedSpg.id;
        anyMatched = true;
      }

      final matchedProduct = productState.products.firstWhereOrNull(
        (p) => p.name.trim().toUpperCase() == item.productName,
      );
      if (matchedProduct != null) {
        _productMappings[item.productName] = matchedProduct.id;
        anyMatched = true;
      }
    }
    
    _hasAutoMatched = true;
    
    if (anyMatched) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    }
  }

  void _showSpgPickerDialog(String spgName) {
    final spgState = context.read<EventSpgBloc>().state;
    if (spgState is! AvailableSpgsLoaded) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    border: Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people_outline, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SELECT_SPG_MAPPING',
                              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              spgName,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...spgState.spgs.map((spg) {
                          final isSelected = _spgMappings[spgName] == spg.id;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _spgMappings[spgName] = spg.id;
                              });
                              Navigator.pop(bottomSheetContext);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.secondary.withOpacity(0.1) : AppColors.surfaceContainerLowest,
                                border: const Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      spg.name.toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: isSelected ? AppColors.secondary : AppColors.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check, color: AppColors.secondary, size: 18),
                                ],
                              ),
                            ),
                          );
                        }),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _spgMappings.remove(spgName);
                            });
                            Navigator.pop(bottomSheetContext);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              border: Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.clear, color: AppColors.error, size: 18),
                                const SizedBox(width: 12),
                                Text(
                                  'CLEAR_MAPPING',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showProductPickerDialog(String productName) {
    final productState = context.read<EventProductBloc>().state;
    if (productState is! AvailableProductsLoaded) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainer,
                    border: Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SELECT_PRODUCT_MAPPING',
                              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              productName,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...productState.products.map((product) {
                          final isSelected = _productMappings[productName] == product.id;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _productMappings[productName] = product.id;
                              });
                              Navigator.pop(bottomSheetContext);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.secondary.withOpacity(0.1) : AppColors.surfaceContainerLowest,
                                border: const Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.name.toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        color: isSelected ? AppColors.secondary : AppColors.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check, color: AppColors.secondary, size: 18),
                                ],
                              ),
                            ),
                          );
                        }),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _productMappings.remove(productName);
                            });
                            Navigator.pop(bottomSheetContext);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              border: Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.clear, color: AppColors.error, size: 18),
                                const SizedBox(width: 12),
                                Text(
                                  'CLEAR_MAPPING',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<BulkSalesItem> _buildSalesItems() {
    final items = <BulkSalesItem>[];
    for (final importItem in widget.importResult.salesItems) {
      final spgId = _spgMappings[importItem.spgName];
      final productId = _productMappings[importItem.productName];
      if (spgId != null && productId != null && importItem.qtySold > 0) {
        items.add(BulkSalesItem(
          spgId: spgId,
          productId: productId,
          qtySold: importItem.qtySold,
        ));
      }
    }
    return items;
  }

  List<BulkUpsertCashItem> _buildCashItems() {
    final items = <BulkUpsertCashItem>[];
    for (final cashItem in widget.importResult.cashItems) {
      final spgId = _spgMappings[cashItem.spgName];
      if (spgId != null) {
        items.add(BulkUpsertCashItem(
          spgId: spgId,
          cashReceived: cashItem.cashReceived,
          qrisReceived: cashItem.qrisReceived,
        ));
      }
    }
    return items;
  }

  int _countUnmatched() {
    int count = 0;
    for (final item in widget.importResult.salesItems) {
      if (_spgMappings[item.spgName] == null || _productMappings[item.productName] == null) {
        count++;
      }
    }
    return count;
  }

  void _executeImport() {
    final salesItems = _buildSalesItems();
    if (salesItems.isEmpty) return;

    setState(() => _isSaving = true);

    context.read<SalesBloc>().add(
      BulkReplaceSalesEvent(
        eventId: widget.eventId,
        salesItems: salesItems,
      ),
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
              'IMPORT_TELEMETRY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const Text(
              'SALES_DATA_MAPPING',
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
      ),
      body: BlocConsumer<SalesBloc, SalesState>(
        listener: (context, state) {
          if (!state.isLoading && _isSaving) {
            if (state.errorMessage == null) {
              // Sales done, now import cash
              final cashItems = _buildCashItems();
              if (cashItems.isNotEmpty) {
                setState(() {
                  _isSaving = false;
                  _isCashSaving = true;
                });
                context.read<CashBloc>().add(
                  BulkUpsertCashEvent(
                    eventId: widget.eventId,
                    cashItems: cashItems,
                  ),
                );
              } else {
                setState(() => _isSaving = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('SALES_DATA_IMPORTED_SUCCESS'),
                    backgroundColor: AppColors.success,
                  ),
                );
                context.pop();
              }
            } else {
              setState(() => _isSaving = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('SALES_IMPORT_ERROR: ${state.errorMessage!.toUpperCase()}')),
              );
            }
          }
        },
        builder: (context, salesState) {
          return BlocConsumer<CashBloc, CashState>(
            listener: (context, cashState) {
              if (!cashState.isLoading && _isCashSaving) {
                setState(() => _isCashSaving = false);
                if (cashState.errorMessage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('SALES_AND_CASH_IMPORTED_SUCCESS'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('CASH_IMPORT_ERROR: ${cashState.errorMessage!.toUpperCase()}')),
                  );
                }
              }
            },
            builder: (context, cashState) {
              return BlocBuilder<EventSpgBloc, EventSpgState>(
                builder: (context, spgState) {
                  return BlocBuilder<EventProductBloc, EventProductState>(
                    builder: (context, productState) {
                      if (spgState is EventSpgLoading || productState is EventProductLoading) {
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      }

                      if (spgState is! AvailableSpgsLoaded || productState is! AvailableProductsLoaded) {
                        return _buildEmptyState();
                      }

                      _autoMatch(spgState, productState);

                      final unmatchedCount = _countUnmatched();
                      final matchedCount = widget.importResult.salesItems.length - unmatchedCount;

                      return CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(child: _buildSummary(matchedCount, unmatchedCount)),
                          if (widget.importResult.cashItems.isNotEmpty)
                            SliverToBoxAdapter(child: _buildCashSummary(spgState)),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final item = widget.importResult.salesItems[index];
                                  final spgMatched = _spgMappings[item.spgName] != null;
                                  final productMatched = _productMappings[item.productName] != null;
                                  final fullyMatched = spgMatched && productMatched;

                                  return _buildImportRow(
                                    context,
                                    item,
                                    spgMatched,
                                    productMatched,
                                    fullyMatched,
                                    spgState,
                                    productState,
                                  );
                                },
                                childCount: widget.importResult.salesItems.length,
                              ),
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
          },
        ),
        bottomNavigationBar: _buildBottomAction(),
      );
    }

  Widget _buildSummary(int matched, int unmatched) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MAPPING_TELEMETRY',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Text(
                        'MATCHED: $matched',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.success),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (unmatched > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Text(
                          'UNMATCHED: $unmatched',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.error),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'TOTAL_ROWS',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.onSurfaceVariant),
              ),
              Text(
                '${widget.importResult.salesItems.length}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashSummary(AvailableSpgsLoaded spgState) {
    final totalCash = widget.importResult.cashItems.fold(0.0, (sum, item) => sum + item.cashReceived);
    final totalQris = widget.importResult.cashItems.fold(0.0, (sum, item) => sum + item.qrisReceived);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.tertiary, size: 16),
              const SizedBox(width: 8),
              const Text(
                'CASH_IMPORT_SUMMARY',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.surfaceContainerHigh),
            ),
            child: Column(
              children: [
                ...widget.importResult.cashItems.map((cashItem) {
                  final matchedSpg = spgState.spgs.firstWhereOrNull(
                    (s) => s.name.trim().toUpperCase() == cashItem.spgName,
                  );
                  final spgId = _spgMappings[cashItem.spgName];
                  final isMatched = spgId != null;

                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.surfaceContainerHigh)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            matchedSpg?.name.toUpperCase() ?? cashItem.spgName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isMatched ? AppColors.onSurface : AppColors.error,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'CASH',
                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant),
                              ),
                              Text(
                                _formatCurrency(cashItem.cashReceived),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'QRIS',
                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant),
                              ),
                              Text(
                                _formatCurrency(cashItem.qrisReceived),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.tertiary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(color: AppColors.surfaceContainer),
                  child: Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text(
                          'TOTAL',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.secondary),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _formatCurrency(totalCash),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _formatCurrency(totalQris),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.tertiary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    return value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Widget _buildImportRow(
    BuildContext context,
    SalesImportItem item,
    bool spgMatched,
    bool productMatched,
    bool fullyMatched,
    AvailableSpgsLoaded spgState,
    AvailableProductsLoaded productState,
  ) {
    final matchedSpg = spgState.spgs.firstWhereOrNull(
      (s) => s.id == _spgMappings[item.spgName],
    );
    final matchedProduct = productState.products.firstWhereOrNull(
      (p) => p.id == _productMappings[item.productName],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(
          color: fullyMatched ? AppColors.surfaceContainerHigh : AppColors.error.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (!fullyMatched)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1)),
                    child: const Text(
                      'UNMATCHED',
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.error, letterSpacing: 1),
                    ),
                  ),
                Expanded(
                  child: Text(
                    'QTY: ${item.qtySold}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.secondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _showSpgPickerDialog(item.spgName),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(
                          color: spgMatched ? AppColors.success : AppColors.error,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SPG',
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            matchedSpg?.name.toUpperCase() ?? item.spgName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: spgMatched ? AppColors.onSurface : AppColors.error,
                            ),
                          ),
                          if (!spgMatched)
                            const Text(
                              'TAP_TO_SELECT',
                              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.error),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _showProductPickerDialog(item.productName),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(
                          color: productMatched ? AppColors.success : AppColors.error,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PRODUCT',
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1, color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            matchedProduct?.name.toUpperCase() ?? item.productName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: productMatched ? AppColors.onSurface : AppColors.error,
                            ),
                          ),
                          if (!productMatched)
                            const Text(
                              'TAP_TO_SELECT',
                              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.error),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          const Text(
            'NO_SPG_OR_PRODUCT_DATA',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          const Text(
            'SETUP_MISSION_FIRST',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    final unmatchedCount = _countUnmatched();
    final isSavingAny = _isSaving || _isCashSaving;
    final canSave = unmatchedCount == 0 && !isSavingAny;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.surfaceContainerHigh)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (unmatchedCount > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                border: Border.all(color: AppColors.error),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_outlined, color: AppColors.error, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'UNMATCHED_ROWS_DETECTED: $unmatchedCount. TAP_ROWS_TO_FIX_MAPPING.',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isSavingAny ? null : () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    side: const BorderSide(color: AppColors.surfaceContainerHigh),
                  ),
                  child: const Text('CANCEL'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: canSave ? _executeImport : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSave ? AppColors.primary : AppColors.surfaceContainerHigh,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    elevation: 0,
                  ),
                  child: isSavingAny
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isSaving ? 'SALES...' : 'CASH...',
                              style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
                            ),
                          ],
                        )
                      : Text(
                          canSave ? 'COMMIT_IMPORT' : 'FIX_MAPPING_FIRST',
                          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}