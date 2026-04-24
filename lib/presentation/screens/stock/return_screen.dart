import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../blocs/event_product_bloc/event_product_bloc.dart';
import '../../blocs/event_product_bloc/event_product_event.dart';
import '../../blocs/event_product_bloc/event_product_state.dart';
import '../../blocs/spg_bloc/spg_bloc.dart';
import '../../blocs/spg_bloc/spg_event.dart';
import '../../blocs/spg_bloc/spg_state.dart';
import '../../blocs/stock_bloc/stock_bloc.dart';
import '../../blocs/stock_bloc/stock_event.dart';
import '../../blocs/stock_bloc/stock_state.dart';
import '../../../domain/entities/stock_mutation_entity.dart';

class ReturnScreen extends StatefulWidget {
  final String eventId;
  final String spgId;

  const ReturnScreen({super.key, required this.eventId, required this.spgId});

  @override
  State<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends State<ReturnScreen> {
  String? _selectedProductId;
  int _quantity = 0;
  final _noteController = TextEditingController();
  bool _isSubmitting = false;
  int _maxReturnQty = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<EventProductBloc>().add(
      LoadAvailableProducts(eventId: widget.eventId),
    );
    context.read<SpgBloc>().add(LoadAllSpqs());
    context.read<StockBloc>().add(
      LoadStockByEventSpg(eventId: widget.eventId, spgId: widget.spgId),
    );
  }

  void _submitReturn() async {
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk terlebih dahulu')),
      );
      return;
    }

    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah harus lebih dari 0')),
      );
      return;
    }

    if (_quantity > _maxReturnQty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jumlah retur melebihi stok yang tersedia (max: $_maxReturnQty)',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      context.read<StockBloc>().add(
        CreateReturn(
          eventId: widget.eventId,
          spgId: widget.spgId,
          productId: _selectedProductId!,
          qty: _quantity,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Retur stok berhasil disimpan'),
            backgroundColor: AppColors.warning,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan retur: $e'),
            backgroundColor: AppColors.error,
          ),
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
              'LOGISTICS_LINK: RECLAMATION',
              style: const TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                fontSize: 9,
              ),
            ),
            const Text(
              'ASSET RECLAMATION',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
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
            'SOURCE_UNIT_IDENTIFICATION'.toUpperCase(),
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
            'INVENTORY RECLAMATION PROTOCOL. REMOVE ASSETS FROM FIELD UNIT INVENTORY AND RETURN TO SYSTEM POOL.'.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.05),
              border: Border.all(color: AppColors.error.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 16),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'WARNING: RECLAMATION WILL DECREASE UNIT INVENTORY LEVELS. DATA INTEGRITY IS MANDATORY.'.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w900,
                      fontSize: 8,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(AvailableProductsLoaded state) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ASSET_RECLAMATION_POOL'.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  fontSize: 9,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              ...state.assignedProducts.map((assignedProduct) {
                final product = state.products.firstWhere(
                  (p) => p.id == assignedProduct.productId,
                );
                final isSelected = _selectedProductId == product.id;

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
                final availableToReturn = totalGiven - totalReturned;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.warning.withOpacity(0.05) : AppColors.surfaceContainerLowest,
                    border: Border.all(
                      color: isSelected ? AppColors.warning : AppColors.surfaceContainerHigh,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: availableToReturn > 0
                        ? () {
                            setState(() {
                              _selectedProductId = product.id;
                              _maxReturnQty = availableToReturn;
                              _quantity = 0;
                            });
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle_outlined : Icons.circle_outlined,
                            color: isSelected ? AppColors.warning : AppColors.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: availableToReturn > 0 ? null : AppColors.onSurfaceVariant.withOpacity(0.5),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'SKU_ID: ${product.sku}'.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onSurfaceVariant,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    Text(
                                      'RECLAIMABLE: $availableToReturn'.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: availableToReturn > 0 ? AppColors.warning : AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              if (_selectedProductId != null) ...[
                const SizedBox(height: 32),
                Text(
                  'RECLAMATION_QUANTITY'.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 9,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                _QuantityInput(
                  value: _quantity,
                  maxQty: _maxReturnQty,
                  onChanged: (val) {
                    setState(() {
                      _quantity = val;
                    });
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  'RECLAMATION_LOGS (OPTIONAL)'.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 9,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'INPUT REASONING...',
                    hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.5), fontSize: 13),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                    border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.surfaceContainerHigh)),
                    enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.surfaceContainerHigh)),
                    focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.warning)),
                  ),
                ),
              ],
            ],
          ),
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
          onPressed: (_isSubmitting || _selectedProductId == null || _quantity <= 0) ? null : _submitReturn,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
            foregroundColor: AppColors.onSurface,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onSurface),
                )
              : const Text(
                  'EXECUTE RECLAMATION PROTOCOL',
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
    if (newValue > widget.maxQty) {
      newValue = widget.maxQty;
    }
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.surfaceContainerHigh),
        color: AppColors.surfaceContainerLowest,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => _updateValue(widget.value - 1),
            icon: const Icon(Icons.remove, size: 20),
            constraints: const BoxConstraints(minWidth: 54, minHeight: 54),
            color: AppColors.error,
          ),
          Container(
            width: 100,
            height: 54,
            decoration: const BoxDecoration(
              border: Border.symmetric(vertical: BorderSide(color: AppColors.surfaceContainerHigh)),
            ),
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.warning),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (val) {
                final newValue = int.tryParse(val) ?? 0;
                _updateValue(newValue);
              },
            ),
          ),
          IconButton(
            onPressed: () => _updateValue(widget.value + 1),
            icon: const Icon(Icons.add, size: 20),
            constraints: const BoxConstraints(minWidth: 54, minHeight: 54),
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}
