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
      appBar: AppBar(title: const Text('Tambah Stok')),
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
              Expanded(
                child: BlocBuilder<EventProductBloc, EventProductState>(
                  builder: (context, state) {
                    if (state is EventProductLoading) {
                      return const Center(child: CircularProgressIndicator());
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
                    return const Center(child: CircularProgressIndicator());
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
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_circle, color: AppColors.success, size: 24),
              const SizedBox(width: 8),
              Text(
                'TOPUP STOK',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'SPG: $spgName',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih produk dan masukkan jumlah stok tambahan.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(AvailableProductsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PILIH PRODUK',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ...state.assignedProducts.map((assignedProduct) {
            final product = state.products.firstWhere(
              (p) => p.id == assignedProduct.productId,
            );
            final isSelected = _selectedProductId == product.id;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: isSelected ? AppColors.success.withOpacity(0.1) : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.success
                      : AppColors.onSurfaceVariant,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedProductId = product.id;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected
                            ? AppColors.success
                            : AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'SKU: ${product.sku}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.onSurfaceVariant),
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
          const SizedBox(height: 24),
          if (_selectedProductId != null) ...[
            Text(
              'JUMLAH TOPUP',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
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
            const SizedBox(height: 24),
            Text(
              'CATATAN (Opsional)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Contoh: Topup karena stok habis...',
                filled: true,
                fillColor: AppColors.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
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

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error: $message'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed:
              (_isSubmitting || _selectedProductId == null || _quantity <= 0)
              ? null
              : _submitTopup,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: 8),
                    Text(
                      'SIMPAN TOPUP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => _updateValue(widget.value - 1),
            icon: const Icon(
              Icons.remove_circle,
              color: AppColors.error,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                border: InputBorder.none,
              ),
              onChanged: (val) {
                final newValue = int.tryParse(val) ?? 0;
                widget.onChanged(newValue);
              },
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => _updateValue(widget.value + 1),
            icon: const Icon(
              Icons.add_circle,
              color: AppColors.success,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
