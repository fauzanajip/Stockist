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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LOGISTICS_LINK: ACTIVE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
            ),
            Text(
              'INITIAL SUPPLY MANIFEST',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
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
            'PERSONNEL_ASSIGNMENT'.toUpperCase(),
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
            'INITIAL INVENTORY ALLOCATION PROTOCOL. INPUT ALL ASSETS DISTRIBUTED TO UNIT FOR MISSION START.'.toUpperCase(),
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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: state.assignedProducts.length,
      itemBuilder: (context, index) {
        final assignedProduct = state.assignedProducts[index];
        final product = state.products.firstWhere(
          (p) => p.id == assignedProduct.productId,
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            border: Border.all(color: AppColors.surfaceContainerHigh),
          ),
          child: Row(
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
          onPressed: _isSubmitting ? null : _submitDistribusi,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
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
                  'EXECUTE SUPPLY PROTOCOL',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
                ),
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.surfaceContainerHigh),
        color: AppColors.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _updateValue(_value - 1),
            icon: const Icon(Icons.remove, size: 16),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
            color: AppColors.error,
          ),
          Container(
            width: 50,
            height: 40,
            decoration: const BoxDecoration(
              border: Border.symmetric(vertical: BorderSide(color: AppColors.surfaceContainerHigh)),
            ),
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
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
