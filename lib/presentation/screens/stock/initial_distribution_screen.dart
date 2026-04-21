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

class InitialDistributionScreen extends StatefulWidget {
  final String eventId;
  final String spgId;

  const InitialDistributionScreen({
    super.key,
    required this.eventId,
    required this.spgId,
  });

  @override
  State<InitialDistributionScreen> createState() =>
      _InitialDistributionScreenState();
}

class _InitialDistributionScreenState extends State<InitialDistributionScreen> {
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
  }

  void _submitDistribusi() async {
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
        context.read<StockBloc>().add(
          CreateInitialDistribution(
            eventId: widget.eventId,
            spgId: widget.spgId,
            productId: entry.key,
            qty: entry.value,
          ),
        );
      }

      // Wait for a bit to let events process
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Distribusi awal berhasil disimpan')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan distribusi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Distribusi Awal')),
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
          Text(
            'SPG: $spgName',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Input stok awal yang diberikan kepada SPG untuk event ini.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(AvailableProductsLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.assignedProducts.length,
      itemBuilder: (context, index) {
        final assignedProduct = state.assignedProducts[index];
        final product = state.products.firstWhere(
          (p) => p.id == assignedProduct.productId,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _QuantityCounter(
                  initialValue: _quantities[product.id] ?? 0,
                  onChanged: (val) {
                    setState(() {
                      _quantities[product.id] = val;
                    });
                  },
                ),
              ],
            ),
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
          onPressed: _isSubmitting ? null : _submitDistribusi,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan Distribusi'),
        ),
      ),
    );
  }
}

class _QuantityCounter extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onChanged;

  const _QuantityCounter({required this.initialValue, required this.onChanged});

  @override
  State<_QuantityCounter> createState() => _QuantityCounterState();
}

class _QuantityCounterState extends State<_QuantityCounter> {
  late int _value;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller = TextEditingController(text: _value.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValue(int newValue) {
    if (newValue < 0) return;
    setState(() {
      _value = newValue;
      _controller.text = _value.toString();
    });
    widget.onChanged(_value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => _updateValue(_value - 1),
          icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
        ),
        SizedBox(
          width: 60,
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (val) {
              final newValue = int.tryParse(val) ?? 0;
              setState(() => _value = newValue);
              widget.onChanged(_value);
            },
          ),
        ),
        IconButton(
          onPressed: () => _updateValue(_value + 1),
          icon: const Icon(Icons.add_circle_outline, color: AppColors.success),
        ),
      ],
    );
  }
}
