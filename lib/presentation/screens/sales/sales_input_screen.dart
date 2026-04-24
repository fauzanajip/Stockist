import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../domain/entities/stock_mutation_entity.dart';
import '../../blocs/event_product_bloc/event_product_bloc.dart';
import '../../blocs/event_product_bloc/event_product_event.dart';
import '../../blocs/event_product_bloc/event_product_state.dart';
import '../../blocs/sales_bloc/sales_bloc.dart';
import '../../blocs/sales_bloc/sales_event.dart';
import '../../blocs/sales_bloc/sales_state.dart';
import '../../blocs/spg_bloc/spg_bloc.dart';
import '../../blocs/spg_bloc/spg_event.dart';
import '../../blocs/spg_bloc/spg_state.dart';
import '../../blocs/stock_bloc/stock_bloc.dart';
import '../../blocs/stock_bloc/stock_event.dart';
import '../../blocs/stock_bloc/stock_state.dart';

class SalesInputScreen extends StatefulWidget {
  final String eventId;
  final String spgId;

  const SalesInputScreen({
    super.key,
    required this.eventId,
    required this.spgId,
  });

  @override
  State<SalesInputScreen> createState() => _SalesInputScreenState();
}

class _SalesInputScreenState extends State<SalesInputScreen> {
  final Map<String, int> _quantities = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<EventProductBloc>().add(
      LoadAvailableProducts(eventId: widget.eventId),
    );
    context.read<SpgBloc>().add(LoadAllSpqs());
    context.read<StockBloc>().add(
      LoadStockByEventSpg(eventId: widget.eventId, spgId: widget.spgId),
    );
    context.read<SalesBloc>().add(
      LoadSales(eventId: widget.eventId, spgId: widget.spgId),
    );
  }

  void _submitSales() async {
    final productsToSubmit = _quantities.entries
        .where((e) => e.value > 0)
        .toList();

    if (productsToSubmit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan minimal satu produk dengan jumlah > 0'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      for (final entry in productsToSubmit) {
        context.read<SalesBloc>().add(
          UpdateSales(
            eventId: widget.eventId,
            spgId: widget.spgId,
            productId: entry.key,
            qtySold: entry.value,
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Data penjualan berhasil disimpan'),
            backgroundColor: AppColors.secondary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan penjualan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
              'COMMERCE_LOGS: CAPTURE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
            ),
            const Text(
              'REVENUE CAPTURE PROTOCOL',
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
            tooltip: 'SYNC_DATA'.toUpperCase(),
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
            final spg = spgState.spqs.firstWhere(
              (s) => s.id == widget.spgId,
              orElse: () => spgState.spqs.first,
            );
            spgName = spg.name;
          }

          return Column(
            children: [
              _buildHeader(context, spgName),
              Container(height: 1, color: AppColors.surfaceContainerHigh),
              Expanded(
                child: BlocBuilder<EventProductBloc, EventProductState>(
                  builder: (context, state) {
                    if (state is EventProductLoading) {
                      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                    }
                    if (state is EventProductError) {
                      return _buildErrorState(state.message);
                    }
                    if (state is AvailableProductsLoaded) {
                      if (state.assignedProducts.isEmpty) {
                        return _buildEmptyState();
                      }
                      return _buildProductList(state);
                    }
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomAction(),
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
            'ACTIVE_FIELD_UNIT'.toUpperCase(),
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
            'COMMERCE ACTIVITY LOGGING. RECORD REVENUE GENERATED BY UNIT. CURRENT INPUTS WILL OVERWRITE PREVIOUS DATA ENTRIES.'.toUpperCase(),
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

  Widget _buildProductList(AvailableProductsLoaded state) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
        return BlocBuilder<SalesBloc, SalesState>(
          builder: (context, salesState) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: state.assignedProducts.length,
              itemBuilder: (context, index) {
                final assignedProduct = state.assignedProducts[index];
                final product = state.products.firstWhere(
                  (p) => p.id == assignedProduct.productId,
                );

                final mutations = stockState.mutations;
                final totalGiven = mutations
                    .where(
                      (m) =>
                          m.productId == product.id &&
                          m.type != MutationType.returnMutation,
                    )
                    .fold(0, (sum, m) => sum + m.qty);
                final totalReturned = mutations
                    .where(
                      (m) =>
                          m.productId == product.id &&
                          m.type == MutationType.returnMutation,
                    )
                    .fold(0, (sum, m) => sum + m.qty);
                final stockInHand = totalGiven - totalReturned;

                final currentSold = salesState.salesByProduct[product.id] ?? 0;
                final quantity = _quantities[product.id] ?? currentSold;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border.all(color: AppColors.surfaceContainerHigh),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name.toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'SKU_ID: ${product.sku} | PRICE: RP ${assignedProduct.price}'.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurfaceVariant,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                border: Border.all(color: AppColors.surfaceContainerHigh),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'STOCK_LEVEL'.toUpperCase(),
                                    style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant),
                                  ),
                                  Text(
                                    '$stockInHand',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              'UNITS_SOLD: '.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 1,
                              ),
                            ),
                            const Spacer(),
                            _QuantityInput(
                              value: quantity,
                              maxQty: stockInHand,
                              onChanged: (val) {
                                setState(() {
                                  _quantities[product.id] = val;
                                });
                              },
                            ),
                          ],
                        ),
                        if (currentSold > 0 && _quantities[product.id] == null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              color: AppColors.secondary.withOpacity(0.05),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.history_edu_rounded, size: 12, color: AppColors.secondary),
                                  const SizedBox(width: 6),
                                  Text(
                                    'LEGACY_LOG: $currentSold UNITS'.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.secondary,
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
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'NO ASSETS ASSIGNED TO MISSION'.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.pop(),
            style: OutlinedButton.styleFrom(shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            child: const Text('ABORT PROTOCOL'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text('SYSTEM_FAILURE: ${message.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            child: const Text('RETRY SYNC'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    final hasChanges = _quantities.entries.any((e) => e.value > 0);
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
          onPressed: (_isSubmitting || !hasChanges) ? null : _submitSales,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  'COMMIT FINANCIAL DATA',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
        ),
      ),
    );
  }
}

class _QuantityInput extends StatefulWidget {
  final int value;
  final int maxQty;
  final ValueChanged<int> onChanged;

  const _QuantityInput({
    required this.value,
    required this.maxQty,
    required this.onChanged,
  });

  @override
  State<_QuantityInput> createState() => _QuantityInputState();
}

class _QuantityInputState extends State<_QuantityInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(_QuantityInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValue(int newValue) {
    if (newValue < 0) return;
    if (newValue > widget.maxQty && widget.maxQty > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('REVENUE_LIMIT_EXCEEDED: MAX STOCK IS ${widget.maxQty}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
          backgroundColor: AppColors.error,
          // borderRadius: BorderRadius.zero,
          behavior: SnackBarBehavior.floating,
        ),
      );
      newValue = widget.maxQty;
    }
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.surfaceContainerHigh),
        color: AppColors.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _updateValue(widget.value - 1),
            icon: const Icon(Icons.remove, size: 16),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
            color: AppColors.error,
          ),
          Container(
            width: 60,
            height: 40,
            decoration: const BoxDecoration(
              border: Border.symmetric(vertical: BorderSide(color: AppColors.surfaceContainerHigh)),
            ),
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.secondary),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (val) {
                final newValue = int.tryParse(val) ?? 0;
                _updateValue(newValue);
              },
            ),
          ),
          IconButton(
            onPressed: () => _updateValue(widget.value + 1),
            icon: const Icon(Icons.add, size: 16),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}
