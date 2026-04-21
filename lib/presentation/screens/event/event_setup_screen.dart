import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
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
import '../../blocs/stock_bloc/stock_bloc.dart';
import '../../blocs/stock_bloc/stock_event.dart';
import '../../blocs/stock_bloc/stock_state.dart';
import '../../../domain/entities/stock_mutation_entity.dart';

class EventSetupScreen extends StatefulWidget {
  final String eventId;

  const EventSetupScreen({super.key, required this.eventId});

  @override
  State<EventSetupScreen> createState() => _EventSetupScreenState();
}

class _EventSetupScreenState extends State<EventSetupScreen>
    with SingleTickerProviderStateMixin {
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
    context.read<EventProductBloc>().add(
      LoadAvailableProducts(eventId: widget.eventId),
    );
    context.read<EventSpgBloc>().add(
      LoadAvailableSpgs(eventId: widget.eventId),
    );
    context.read<StockBloc>().add(
      LoadStockByEvent(eventId: widget.eventId),
    );
  }

  void _saveSetup() {
    context.goNamed(
      'event_detail',
      pathParameters: {'eventId': widget.eventId},
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Setup berhasil disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Event'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              tabs: const [
                Tab(text: 'Produk'),
                Tab(text: 'SPG'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildProductTab(), _buildSpgTab()],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _saveSetup,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'SIMPAN SETUP',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductTab() {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
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
              if (state is EventProductLoading || stockState.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AvailableProductsLoaded) {
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.products.length,
                  itemBuilder: (context, index) {
                    final product = state.products[index];

                    // Filter warehouse stock for this product
                    final distributorStock = stockState.mutations
                        .where(
                          (m) =>
                              m.productId == product.id &&
                              m.spgId == 'WAREHOUSE' &&
                              m.type == MutationType.distributorToEvent,
                        )
                        .fold(0, (sum, m) => sum + m.qty);

                    final isAssigned = state.assignedProducts.any(
                      (ep) => ep.productId == product.id,
                    );
                    final assignedProduct =
                        isAssigned
                            ? state.assignedProducts.firstWhere(
                              (ep) => ep.productId == product.id,
                            )
                            : EventProductEntity(
                              id: '',
                              eventId: widget.eventId,
                              productId: product.id,
                              price: product.price,
                            );

                    return ProductAssignmentCard(
                      product: product,
                      isAssigned: isAssigned,
                      assignedProduct: assignedProduct,
                      distributorStock: distributorStock,
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
                      onDistributorStockChanged: (qty) {
                        final diff = qty - distributorStock;
                        if (diff != 0) {
                          context.read<StockBloc>().add(
                            CreateDistributorStock(
                              eventId: widget.eventId,
                              productId: product.id,
                              qty: diff,
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  Widget _buildSpgTab() {
    return BlocBuilder<EventSpgBloc, EventSpgState>(
      builder: (context, state) {
        if (state is EventSpgLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AvailableSpgsLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: state.spgs.length,
            itemBuilder: (context, index) {
              final spg = state.spgs[index];
              final assignedSpg = state.assignedSpgs.firstWhere(
                (es) => es.spgId == spg.id,
                orElse: () => EventSpgEntity(
                  id: '',
                  eventId: widget.eventId,
                  spgId: spg.id,
                ),
              );
              return SpgAssignmentCard(
                spg: spg,
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
                      AssignSpg(eventId: widget.eventId, spgId: spg.id),
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
        return const SizedBox.shrink();
      },
    );
  }
}

class ProductAssignmentCard extends StatefulWidget {
  final ProductEntity product;
  final bool isAssigned;
  final EventProductEntity assignedProduct;
  final int distributorStock;
  final Function(double) onToggle;
  final Function(double) onPriceChanged;
  final Function(int) onDistributorStockChanged;

  const ProductAssignmentCard({
    super.key,
    required this.product,
    required this.isAssigned,
    required this.assignedProduct,
    required this.distributorStock,
    required this.onToggle,
    required this.onPriceChanged,
    required this.onDistributorStockChanged,
  });

  @override
  State<ProductAssignmentCard> createState() => _ProductAssignmentCardState();
}

class _ProductAssignmentCardState extends State<ProductAssignmentCard> {
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late double _currentPrice;
  late int _currentStock;

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.isAssigned
        ? widget.assignedProduct.price
        : widget.product.price;
    _currentStock = widget.distributorStock;
    
    _priceController = TextEditingController(
      text: _currentPrice.toInt().toString(),
    );
    _stockController = TextEditingController(
      text: _currentStock.toString(),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: widget.isAssigned
            ? AppColors.surfaceContainerHigh
            : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: widget.isAssigned
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'SKU: ${widget.product.sku}',
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: widget.isAssigned,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => widget.onToggle(_currentPrice),
                ),
              ],
            ),
            if (widget.isAssigned) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'HARGA EVENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 120,
                    height: 40,
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                      decoration: const InputDecoration(
                        prefixText: 'Rp',
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onChanged: (v) => _currentPrice = double.tryParse(v) ?? 0,
                      onEditingComplete: () {
                        widget.onPriceChanged(_currentPrice);
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'STOK DISTRIBUTOR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 120,
                    height: 40,
                    child: TextField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      decoration: const InputDecoration(
                        suffixText: 'pcs',
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onChanged: (v) => _currentStock = int.tryParse(v) ?? 0,
                      onEditingComplete: () {
                        widget.onDistributorStockChanged(_currentStock);
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                ],
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
  final List<SpbEntity> spbs;
  final bool isAssigned;
  final String? spbId;
  final VoidCallback onToggle;
  final Function(String?) onSpbChanged;

  const SpgAssignmentCard({
    super.key,
    required this.spg,
    required this.spbs,
    required this.isAssigned,
    required this.spbId,
    required this.onToggle,
    required this.onSpbChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isAssigned
            ? AppColors.surfaceContainerHigh
            : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: isAssigned
            ? Border.all(color: AppColors.success.withOpacity(0.5), width: 1)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.success.withOpacity(0.1),
                  child: Text(
                    spg.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    spg.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Switch(
                  value: isAssigned,
                  activeThumbColor: AppColors.success,
                  onChanged: (v) => onToggle(),
                ),
              ],
            ),
            if (isAssigned) ...[
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'ASSIGN SPB',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: spbId,
                        isExpanded: true,
                        hint: const Text(
                          'Pilih SPB',
                          style: TextStyle(fontSize: 14),
                        ),
                        dropdownColor: AppColors.surfaceContainerHigh,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Tidak ada SPB'),
                          ),
                          ...spbs.map(
                            (s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(s.name),
                            ),
                          ),
                        ],
                        onChanged: (v) => onSpbChanged(v),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
