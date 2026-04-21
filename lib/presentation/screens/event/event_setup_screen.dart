import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../dependency_injection.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/spg_entity.dart';
import '../../../domain/entities/spb_entity.dart';
import '../../../domain/entities/event_product_entity.dart';
import '../../../domain/entities/event_spg_entity.dart';
import '../../blocs/product_bloc/product_bloc.dart';
import '../../blocs/product_bloc/product_event.dart';
import '../../blocs/product_bloc/product_state.dart';
import '../../blocs/spg_bloc/spg_bloc.dart';
import '../../blocs/spg_bloc/spg_event.dart';
import '../../blocs/spg_bloc/spg_state.dart';
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

class _EventSetupScreenState extends State<EventSetupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, double> _selectedProductPrices = {};
  Map<String, String?> _selectedSpgSpbs = {};
  List<String> _selectedProductIds = [];
  List<String> _selectedSpgIds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    context.read<ProductBloc>().add(LoadActiveProducts());
    context.read<SpgBloc>().add(LoadActiveSpqs());
    context.read<EventProductBloc>().add(LoadAvailableProducts(eventId: widget.eventId));
    context.read<EventSpgBloc>().add(LoadAvailableSpgs(eventId: widget.eventId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get eventId => widget.eventId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
          create: (context) => sl<ProductBloc>()..add(LoadActiveProducts()),
        ),
        BlocProvider<SpgBloc>(
          create: (context) => sl<SpgBloc>()..add(LoadActiveSpqs()),
        ),
        BlocProvider<EventProductBloc>(
          create: (context) => sl<EventProductBloc>()..add(LoadAvailableProducts(eventId: eventId)),
        ),
        BlocProvider<EventSpgBloc>(
          create: (context) => sl<EventSpgBloc>()..add(LoadAvailableSpgs(eventId: eventId)),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Setup Event'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.inventory_2), text: 'Produk'),
              Tab(icon: Icon(Icons.people), text: 'SPG'),
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _saveSetup,
          icon: const Icon(Icons.save),
          label: const Text('Simpan Setup'),
        ),
      ),
    );
  }

  Widget _buildProductTab() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, productState) {
        return BlocBuilder<EventProductBloc, EventProductState>(
          builder: (context, eventProductState) {
            if (productState is ProductLoading || eventProductState is EventProductLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (productState is ProductError) {
              return Center(child: Text('Error: ${productState.message}'));
            }

            if (productState is ProductsLoaded) {
              final assignedProducts = eventProductState is AvailableProductsLoaded
                  ? eventProductState.assignedProducts
                  : <EventProductEntity>[];

              final assignedProductIds = assignedProducts.map((p) => p.productId).toList();

              for (final assigned in assignedProducts) {
                if (!_selectedProductIds.contains(assigned.productId)) {
                  _selectedProductIds.add(assigned.productId);
                  _selectedProductPrices[assigned.productId] = assigned.price;
                }
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'Pilih produk yang akan dijual',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text(
                          '${_selectedProductIds.length} dipilih',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: productState.products.length,
                      itemBuilder: (context, index) {
                        final product = productState.products[index];
                        final isSelected = _selectedProductIds.contains(product.id);
                        final defaultPrice = _selectedProductPrices[product.id] ?? product.price;

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedProductIds.add(product.id);
                                  _selectedProductPrices[product.id] = product.price;
                                } else {
                                  _selectedProductIds.remove(product.id);
                                  _selectedProductPrices.remove(product.id);
                                }
                              });
                            },
                            title: Text(product.name),
                            subtitle: Text(
                              'SKU: ${product.sku}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            secondary: isSelected
                                ? InkWell(
                                    onTap: () => _showPriceDialog(product),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Rp ${defaultPrice.toInt()}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                : null,
                            activeColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text('Tidak ada produk'));
          },
        );
      },
    );
  }

  Widget _buildSpgTab() {
    return BlocBuilder<SpgBloc, SpgState>(
      builder: (context, spgState) {
        return BlocBuilder<EventSpgBloc, EventSpgState>(
          builder: (context, eventSpgState) {
            if (spgState is SpgLoading || eventSpgState is EventSpgLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (spgState is SpgError) {
              return Center(child: Text('Error: ${spgState.message}'));
            }

            if (spgState is SpqsLoaded) {
              final assignedSpgs = eventSpgState is AvailableSpgsLoaded
                  ? eventSpgState.assignedSpgs
                  : <EventSpgEntity>[];

              final spbs = eventSpgState is AvailableSpgsLoaded
                  ? eventSpgState.spbs
                  : <SpbEntity>[];

              for (final assigned in assignedSpgs) {
                if (!_selectedSpgIds.contains(assigned.spgId)) {
                  _selectedSpgIds.add(assigned.spgId);
                  _selectedSpgSpbs[assigned.spgId] = assigned.spbId;
                }
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'Pilih SPG yang aktif di event ini',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text(
                          '${_selectedSpgIds.length} dipilih',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: spgState.spqs.length,
                      itemBuilder: (context, index) {
                        final spg = spgState.spqs[index];
                        final isSelected = _selectedSpgIds.contains(spg.id);

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedSpgIds.add(spg.id);
                                    _selectedSpgSpbs[spg.id] = null;
                                  } else {
                                    _selectedSpgIds.remove(spg.id);
                                    _selectedSpgSpbs.remove(spg.id);
                                  }
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                            title: Text(spg.name),
                            trailing: isSelected
                                ? DropdownButton<String?>(
                                  value: _selectedSpgSpbs[spg.id],
                                  hint: const Text('SPB'),
                                  items: [
                                    const DropdownMenuItem(value: null, child: Text('Tanpa SPB')),
                                    ...spbs.map((spb) => DropdownMenuItem(
                                      value: spb.id,
                                      child: Text(spb.name),
                                    )),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSpgSpbs[spg.id] = value;
                                    });
                                  },
                                )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text('Tidak ada SPG'));
          },
        );
      },
    );
  }

  void _showPriceDialog(ProductEntity product) {
    final priceController = TextEditingController(
      text: (_selectedProductPrices[product.id] ?? product.price).toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Harga ${product.name}'),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Harga',
            prefixText: 'Rp ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceController.text) ?? product.price;
              setState(() {
                _selectedProductPrices[product.id] = price;
              });
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _saveSetup() {
    if (_selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 produk')),
      );
      return;
    }

    if (_selectedSpgIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 SPG')),
      );
      return;
    }

    final assignedProducts = _selectedProductIds.map((productId) {
      return EventProductEntity(
        id: '',
        eventId: eventId,
        productId: productId,
        price: _selectedProductPrices[productId] ?? 0,
      );
    }).toList();

    final assignedSpgs = _selectedSpgIds.map((spgId) {
      return EventSpgEntity(
        id: '',
        eventId: eventId,
        spgId: spgId,
        spbId: _selectedSpgSpbs[spgId],
      );
    }).toList();

    context.read<EventProductBloc>().add(SaveAllAssignedProducts(
      eventId: eventId,
      assignedProducts: assignedProducts,
    ));
    context.read<EventSpgBloc>().add(SaveAllAssignedSpgs(
      eventId: eventId,
      assignedSpgs: assignedSpgs,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Setup berhasil disimpan'),
        backgroundColor: AppColors.success,
      ),
    );

    context.goNamed('event_detail', pathParameters: {'eventId': eventId});
  }
}
