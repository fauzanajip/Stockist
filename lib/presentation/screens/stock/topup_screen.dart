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

class TopupScreen extends StatefulWidget {
  final String eventId;
  final String spgId;

  const TopupScreen({super.key, required this.eventId, required this.spgId});

  @override
  State<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends State<TopupScreen> {
  String? _selectedProductId;
  int _quantity = 0;
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

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
  }

  void _submitTopup() async {
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

    setState(() => _isSubmitting = true);

    try {
      context.read<StockBloc>().add(
        CreateTopup(
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
          const SnackBar(content: Text('Topup stok berhasil disimpan')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan topup: $e')));
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
              'LOGISTICS_LINK: RESUPPLY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
            ),
            const Text(
              'RESUPPLY PROTOCOL',
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
            'TARGET_UNIT_IDENTIFICATION'.toUpperCase(),
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
            'INVENTORY REPLENISHMENT PROTOCOL. AUTHORIZE ADDITIONAL ASSET ALLOCATION TO ACTIVE FIELD UNIT.'.toUpperCase(),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ASSET_REGISTRY_SELECTION'.toUpperCase(),
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

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.success.withOpacity(0.05) : AppColors.surfaceContainerLowest,
                border: Border.all(
                  color: isSelected ? AppColors.success : AppColors.surfaceContainerHigh,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedProductId = product.id;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle_outlined : Icons.circle_outlined,
                        color: isSelected ? AppColors.success : AppColors.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 16),
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
                              'SKU_ID: ${product.sku}'.toUpperCase(),
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
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_selectedProductId != null) ...[
            const SizedBox(height: 32),
            Text(
              'ALLOCATION_QUANTITY'.toUpperCase(),
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
              onChanged: (val) {
                setState(() {
                  _quantity = val;
                });
              },
            ),
            const SizedBox(height: 32),
            Text(
              'REASON_FOR_ALLOCATION (OPTIONAL)'.toUpperCase(),
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
                focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
          ],
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
          onPressed: (_isSubmitting || _selectedProductId == null || _quantity <= 0) ? null : _submitTopup,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
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
                  'EXECUTE RESUPPLY PROTOCOL',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
        ),
      ),
    );
  }
}

class _QuantityInput extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _QuantityInput({required this.value, required this.onChanged});

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
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.success),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (val) {
                final newValue = int.tryParse(val) ?? 0;
                widget.onChanged(newValue);
              },
            ),
          ),
          IconButton(
            onPressed: () => _updateValue(widget.value + 1),
            icon: const Icon(Icons.add, size: 20),
            constraints: const BoxConstraints(minWidth: 54, minHeight: 54),
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}
