import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart' as app_formatters;
import '../../../domain/entities/event_product_entity.dart';
import '../../../domain/entities/event_spg_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/spg_entity.dart';
import '../../../domain/entities/spb_entity.dart';
import '../../blocs/event_product_bloc/event_product_bloc.dart';
import '../../blocs/event_product_bloc/event_product_event.dart';
import '../../blocs/event_product_bloc/event_product_state.dart';
import '../../blocs/event_spg_bloc/event_spg_bloc.dart';
import '../../blocs/event_spg_bloc/event_spg_event.dart';
import '../../blocs/event_spg_bloc/event_spg_state.dart';

class EventSetupScreen extends StatefulWidget {
  final String eventId;

  const EventSetupScreen({super.key, required this.eventId});

  @override
  State<EventSetupScreen> createState() => _EventSetupScreenState();
}

class _EventSetupScreenState extends State<EventSetupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<EventProductBloc>().add(LoadAvailableProducts(eventId: widget.eventId));
    context.read<EventSpgBloc>().add(LoadAvailableSpgs(eventId: widget.eventId));
  }

  void _saveSetup() {
    context.goNamed('event_detail', pathParameters: {'eventId': widget.eventId});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Setup berhasil disimpan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Event'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Produk', icon: Icon(Icons.inventory_2)),
            Tab(text: 'SPG', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductTab(),
          _buildSpgTab(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _saveSetup,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Simpan Setup'),
          ),
        ),
      ),
    );
  }

  Widget _buildProductTab() {
    return BlocListener<EventProductBloc, EventProductState>(
      listener: (context, state) {
        if (state is ProductUnassigned) {
          context.read<EventProductBloc>().add(
            LoadAvailableProducts(eventId: widget.eventId),
          );
        }
      },
      child: BlocBuilder<EventProductBloc, EventProductState>(
        builder: (context, state) {
          if (state is EventProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is EventProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is AvailableProductsLoaded) {
            if (state.products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada produk',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan produk di Settings terlebih dahulu',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                final product = state.products[index];
                final isAssigned = state.assignedProducts.any((ep) => ep.productId == product.id);
                EventProductEntity assignedProduct;
                
                if (isAssigned) {
                  assignedProduct = state.assignedProducts.firstWhere(
                    (ep) => ep.productId == product.id,
                  );
                } else {
                  assignedProduct = EventProductEntity(
                    id: '',
                    eventId: widget.eventId,
                    productId: product.id,
                    price: product.price,
                  );
                }
                
                return ProductAssignmentCard(
                  product: product,
                  eventId: widget.eventId,
                  isAssigned: isAssigned,
                  assignedProduct: assignedProduct,
                  onToggle: (price) {
                    if (isAssigned) {
                      context.read<EventProductBloc>().add(
                        UnassignProduct(eventProductId: assignedProduct.id),
                      );
                    } else {
                      context.read<EventProductBloc>().add(
                        AssignProduct(
                          eventId: widget.eventId,
                          productId: product.id,
                          price: price,
                        ),
                      );
                    }
                  },
                  onPriceChanged: (price) {
                    if (isAssigned) {
                      context.read<EventProductBloc>().add(
                        UpdateEventProductPrice(
                          eventProductId: assignedProduct.id,
                          price: price,
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildSpgTab() {
    return BlocBuilder<EventSpgBloc, EventSpgState>(
      builder: (context, state) {
        if (state is EventSpgLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is EventSpgError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadData(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is AvailableSpgsLoaded) {
          if (state.spgs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: AppColors.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada SPG',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan SPG di Settings terlebih dahulu',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.spgs.length,
            itemBuilder: (context, index) {
              final spg = state.spgs[index];
              final assignedSpg = state.assignedSpgs.firstWhere(
                (es) => es.spgId == spg.id,
                orElse: () => EventSpgEntity(
                  id: '',
                  eventId: widget.eventId,
                  spgId: spg.id,
                  spbId: null,
                ),
              );
              return SpgAssignmentCard(
                spg: spg,
                spgs: state.spgs,
                spbs: state.spbs,
                isAssigned: assignedSpg.id.isNotEmpty,
                spbId: assignedSpg.spbId,
                onToggle: () {
                  if (assignedSpg.id.isNotEmpty) {
                    context.read<EventSpgBloc>().add(
                      UnassignSpg(eventSpgId: assignedSpg.id),
                    );
                  } else {
                    context.read<EventSpgBloc>().add(
                      AssignSpg(eventId: widget.eventId, spgId: spg.id, spbId: null),
                    );
                  }
                },
                onSpbChanged: (spbId) {
                  context.read<EventSpgBloc>().add(
                    UpdateEventSpgSpb(eventSpgId: assignedSpg.id, spbId: spbId),
                  );
                },
              );
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class ProductAssignmentCard extends StatefulWidget {
  final ProductEntity product;
  final String eventId;
  final bool isAssigned;
  final EventProductEntity assignedProduct;
  final Function(double) onToggle;
  final Function(double) onPriceChanged;

  const ProductAssignmentCard({
    super.key,
    required this.product,
    required this.eventId,
    required this.isAssigned,
    required this.assignedProduct,
    required this.onToggle,
    required this.onPriceChanged,
  });

  @override
  State<ProductAssignmentCard> createState() => _ProductAssignmentCardState();
}

class _ProductAssignmentCardState extends State<ProductAssignmentCard> {
  late TextEditingController _priceController;
  late double _currentPrice;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.isAssigned ? widget.assignedProduct.price : widget.product.price;
    _priceController = TextEditingController(text: _currentPrice.toInt().toString());
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                        widget.product.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.product.sku != null)
                        Text(
                          'SKU: ${widget.product.sku}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                Switch(
                  value: widget.isAssigned,
                  onChanged: (value) {
                    widget.onToggle(_currentPrice);
                  },
                ),
              ],
            ),
            if (widget.isAssigned) ...[
              const SizedBox(height: 12),
              Text(
                'Harga Produk',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.money),
                ),
                onChanged: (value) {
                  final price = double.tryParse(value) ?? 0;
                  setState(() => _currentPrice = price);
                },
                onEditingComplete: () {
                  widget.onPriceChanged(_currentPrice);
                  FocusScope.of(context).unfocus();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SpgAssignmentCard extends StatelessWidget {
  final SpgEntity spg;
  final List<SpgEntity> spgs;
  final List<SpbEntity> spbs;
  final bool isAssigned;
  final String? spbId;
  final VoidCallback onToggle;
  final Function(String?) onSpbChanged;

  const SpgAssignmentCard({
    super.key,
    required this.spg,
    required this.spgs,
    required this.spbs,
    required this.isAssigned,
    required this.spbId,
    required this.onToggle,
    required this.onSpbChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    spg.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: isAssigned,
                  onChanged: (_) => onToggle(),
                ),
              ],
            ),
            if (isAssigned) ...[
              const SizedBox(height: 12),
              Text(
                'Assign SPB (Opsional)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: spbId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Pilih SPB',
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Tidak ada SPB'),
                  ),
                  ...spbs.map((spb) {
                    return DropdownMenuItem(
                      value: spb.id,
                      child: Text(spb.name),
                    );
                  }),
                ],
                onChanged: (value) => onSpbChanged(value),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
