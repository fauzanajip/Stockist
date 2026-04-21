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
import '../../blocs/sales_bloc/sales_bloc.dart';
import '../../blocs/sales_bloc/sales_event.dart';
import '../../blocs/sales_bloc/sales_state.dart';
import '../../../domain/entities/stock_mutation_entity.dart';
import '../../../domain/entities/sales_entity.dart';

class EventSetupScreen extends StatefulWidget {
  final String eventId;

  const EventSetupScreen({super.key, required this.eventId});

  @override
  State<EventSetupScreen> createState() => _EventSetupScreenState();
}

class _EventSetupScreenState extends State<EventSetupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Search & Filter State
  String _productSearchQuery = '';
  String _spgSearchQuery = '';
  bool _showOnlyActiveProducts = false;
  bool _showOnlyActiveSpgs = false;

  // Draft State (Product ID -> Entity)
  final Map<String, EventProductEntity> _draftProducts = {};
  final Map<String, EventSpgEntity> _draftSpgs = {};
  final Map<String, int> _draftStocks = {};

  // History State for Integrity
  List<StockMutationEntity> _allMutations = [];
  List<SalesEntity> _allSales = [];

  bool _isInitialized = false;

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
    context.read<StockBloc>().add(LoadStockByEvent(eventId: widget.eventId));
    // Needed for integrity check
    context.read<SalesBloc>().add(LoadAllSalesByEvent(eventId: widget.eventId));
  }

  void _saveSetup() {
    // 1. Sync Products
    context.read<EventProductBloc>().add(
      SyncEventProducts(
        eventId: widget.eventId,
        assignedProducts: _draftProducts.values.toList(),
      ),
    );

    // 2. Sync SPGs
    context.read<EventSpgBloc>().add(
      SyncEventSpgs(
        eventId: widget.eventId,
        assignedSpgs: _draftSpgs.values.toList(),
      ),
    );

    // 3. Sync Stock Mutations (Delta approach)
    final stockState = context.read<StockBloc>().state;
    for (final productId in _draftStocks.keys) {
      final initialStock = stockState.mutations
          .where(
            (m) =>
                m.productId == productId &&
                m.spgId == 'WAREHOUSE' &&
                m.type == MutationType.distributorToEvent,
          )
          .fold(0, (sum, m) => sum + m.qty);

      final diff = _draftStocks[productId]! - initialStock;
      if (diff != 0) {
        context.read<StockBloc>().add(
          CreateDistributorStock(
            eventId: widget.eventId,
            productId: productId,
            qty: diff,
          ),
        );
      }
    }

    context.goNamed('home');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Setup berhasil disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Event')),
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

  Widget _buildSearchBar({
    required Function(String) onChanged,
    required VoidCallback onFilterToggle,
    required bool isFilterActive,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: onChanged,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  icon: const Icon(
                    Icons.search,
                    size: 20,
                    color: AppColors.onSurfaceVariant,
                  ),
                  hintText: hint,
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: onFilterToggle,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isFilterActive
                    ? AppColors.primary
                    : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.filter_list,
                size: 20,
                color: isFilterActive ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTab() {
    return BlocBuilder<SalesBloc, SalesState>(
      builder: (context, salesState) {
        return BlocBuilder<StockBloc, StockState>(
          builder: (context, stockState) {
            return BlocBuilder<EventProductBloc, EventProductState>(
              builder: (context, state) {
                if (state is EventProductLoading || stockState.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AvailableProductsLoaded) {
                  // Initialize drafts if not done
                  if (!_isInitialized) {
                    for (var ep in state.assignedProducts) {
                      _draftProducts[ep.productId] = ep;
                    }
                    for (var p in state.products) {
                      final distStock = stockState.mutations
                          .where(
                            (m) =>
                                m.productId == p.id &&
                                m.spgId == 'WAREHOUSE' &&
                                m.type == MutationType.distributorToEvent,
                          )
                          .fold(0, (sum, m) => sum + m.qty);
                      _draftStocks[p.id] = distStock;
                    }
                    _isInitialized = true;
                  }

                  final filteredProducts = state.products.where((p) {
                    final matchesSearch =
                        p.name.toLowerCase().contains(
                          _productSearchQuery.toLowerCase(),
                        ) ||
                        p.sku.toLowerCase().contains(
                          _productSearchQuery.toLowerCase(),
                        );
                    final isActive = _draftProducts.containsKey(p.id);
                    if (_showOnlyActiveProducts) {
                      return matchesSearch && isActive;
                    }
                    return matchesSearch;
                  }).toList();

                  return Column(
                    children: [
                      _buildSearchBar(
                        hint: 'Cari produk atau SKU...',
                        onChanged: (v) =>
                            setState(() => _productSearchQuery = v),
                        onFilterToggle: () => setState(
                          () => _showOnlyActiveProducts =
                              !_showOnlyActiveProducts,
                        ),
                        isFilterActive: _showOnlyActiveProducts,
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            final isAssigned = _draftProducts.containsKey(
                              product.id,
                            );
                            final assignedProduct = isAssigned
                                ? _draftProducts[product.id]!
                                : EventProductEntity(
                                    id: '',
                                    eventId: widget.eventId,
                                    productId: product.id,
                                    price: product.price,
                                  );

                            // DATA INTEGRITY CHECK
                            final hasHistory =
                                stockState.mutations.any(
                                  (m) =>
                                      m.productId == product.id &&
                                      m.spgId != 'WAREHOUSE',
                                ) ||
                                salesState.allSales.any(
                                  (s) => s.productId == product.id,
                                );

                            return ProductAssignmentCard(
                              product: product,
                              isAssigned: isAssigned,
                              assignedProduct: assignedProduct,
                              distributorStock: _draftStocks[product.id] ?? 0,
                              hasHistory: hasHistory,
                              onToggle: (price) {
                                setState(() {
                                  if (isAssigned) {
                                    _draftProducts.remove(product.id);
                                  } else {
                                    _draftProducts[product.id] =
                                        EventProductEntity(
                                          id: '',
                                          eventId: widget.eventId,
                                          productId: product.id,
                                          price: price,
                                        );
                                  }
                                });
                              },
                              onPriceChanged: (price) {
                                setState(() {
                                  _draftProducts[product.id] = assignedProduct
                                      .copyWith(price: price);
                                });
                              },
                              onDistributorStockChanged: (qty) {
                                setState(() {
                                  _draftStocks[product.id] = qty;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSpgTab() {
    return BlocBuilder<SalesBloc, SalesState>(
      builder: (context, salesState) {
        return BlocBuilder<StockBloc, StockState>(
          builder: (context, stockState) {
            return BlocBuilder<EventSpgBloc, EventSpgState>(
              builder: (context, state) {
                if (state is EventSpgLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AvailableSpgsLoaded) {
                  // Initialize drafts if not done (SPG specific)
                  // Note: _isInitialized is set in Product tab, but we also
                  // need to ensure SPGs are synced if this tab is opened first.
                  for (var es in state.assignedSpgs) {
                    if (!_draftSpgs.containsKey(es.spgId)) {
                      _draftSpgs[es.spgId] = es;
                    }
                  }

                  final filteredSpgs = state.spgs.where((s) {
                    final matchesSearch = s.name.toLowerCase().contains(
                      _spgSearchQuery.toLowerCase(),
                    );
                    final isActive = _draftSpgs.containsKey(s.id);
                    if (_showOnlyActiveSpgs) {
                      return matchesSearch && isActive;
                    }
                    return matchesSearch;
                  }).toList();

                  return Column(
                    children: [
                      _buildSearchBar(
                        hint: 'Cari SPG...',
                        onChanged: (v) => setState(() => _spgSearchQuery = v),
                        onFilterToggle: () => setState(
                          () => _showOnlyActiveSpgs = !_showOnlyActiveSpgs,
                        ),
                        isFilterActive: _showOnlyActiveSpgs,
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filteredSpgs.length,
                          itemBuilder: (context, index) {
                            final spg = filteredSpgs[index];
                            final isAssigned = _draftSpgs.containsKey(spg.id);
                            final assignedSpg = isAssigned
                                ? _draftSpgs[spg.id]!
                                : EventSpgEntity(
                                    id: '',
                                    eventId: widget.eventId,
                                    spgId: spg.id,
                                  );

                            // DATA INTEGRITY CHECK
                            final hasHistory =
                                stockState.mutations.any(
                                  (m) => m.spgId == spg.id,
                                ) ||
                                salesState.allSales.any(
                                  (s) => s.spgId == spg.id,
                                );

                            return SpgAssignmentCard(
                              spg: spg,
                              spbs: state.spbs,
                              isAssigned: isAssigned,
                              spbId: assignedSpg.spbId,
                              hasHistory: hasHistory,
                              onToggle: () {
                                setState(() {
                                  if (isAssigned) {
                                    _draftSpgs.remove(spg.id);
                                  } else {
                                    _draftSpgs[spg.id] = EventSpgEntity(
                                      id: '',
                                      eventId: widget.eventId,
                                      spgId: spg.id,
                                    );
                                  }
                                });
                              },
                              onSpbChanged: (spbId) {
                                setState(() {
                                  _draftSpgs[spg.id] = assignedSpg.copyWith(
                                    spbId: spbId,
                                  );
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        );
      },
    );
  }
}

class ProductAssignmentCard extends StatefulWidget {
  final ProductEntity product;
  final bool isAssigned;
  final EventProductEntity assignedProduct;
  final int distributorStock;
  final bool hasHistory;
  final Function(double) onToggle;
  final Function(double) onPriceChanged;
  final Function(int) onDistributorStockChanged;

  const ProductAssignmentCard({
    super.key,
    required this.product,
    required this.isAssigned,
    required this.assignedProduct,
    required this.distributorStock,
    required this.hasHistory,
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

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.isAssigned
        ? widget.assignedProduct.price
        : widget.product.price;

    _priceController = TextEditingController(
      text: _currentPrice.toInt().toString(),
    );
    _stockController = TextEditingController(
      text: widget.distributorStock.toString(),
    );
  }

  @override
  void didUpdateWidget(ProductAssignmentCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.distributorStock != widget.distributorStock) {
      _stockController.text = widget.distributorStock.toString();
    }
    if (oldWidget.assignedProduct.price != widget.assignedProduct.price) {
      _priceController.text = widget.assignedProduct.price.toInt().toString();
      _currentPrice = widget.assignedProduct.price;
    }
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
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 1,
              )
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
                  onChanged: (v) {
                    if (widget.hasHistory && widget.isAssigned) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Produk tidak bisa dinonaktifkan karena sudah memiliki transaksi.',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    widget.onToggle(_currentPrice);
                  },
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
                      onChanged: (v) {
                        _currentPrice = double.tryParse(v) ?? 0;
                        widget.onPriceChanged(_currentPrice);
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
                      onChanged: (v) {
                        final qty = int.tryParse(v) ?? 0;
                        widget.onDistributorStockChanged(qty);
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
  final bool hasHistory;
  final VoidCallback onToggle;
  final Function(String?) onSpbChanged;

  const SpgAssignmentCard({
    super.key,
    required this.spg,
    required this.spbs,
    required this.isAssigned,
    required this.spbId,
    required this.hasHistory,
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
                  onChanged: (v) {
                    if (hasHistory && isAssigned) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'SPG tidak bisa dinonaktifkan karena sudah memiliki transaksi.',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    onToggle();
                  },
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
