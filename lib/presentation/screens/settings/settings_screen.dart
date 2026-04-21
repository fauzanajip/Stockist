import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../blocs/product_bloc/product_bloc.dart';
import '../../blocs/product_bloc/product_event.dart';
import '../../blocs/product_bloc/product_state.dart';
import '../../blocs/spg_bloc/spg_bloc.dart';
import '../../blocs/spg_bloc/spg_event.dart';
import '../../blocs/spg_bloc/spg_state.dart';
import '../../blocs/spb_bloc/spb_bloc.dart';
import '../../blocs/spb_bloc/spb_event.dart';
import '../../blocs/spb_bloc/spb_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings - Master Data'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Produk', icon: Icon(Icons.inventory_2)),
              Tab(text: 'SPG', icon: Icon(Icons.people)),
              Tab(text: 'SPB', icon: Icon(Icons.person)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProductSettingsTab(),
            SpgSettingsTab(),
            SpbSettingsTab(),
          ],
        ),
      ),
    );
  }
}

class ProductSettingsTab extends StatefulWidget {
  const ProductSettingsTab({super.key});

  @override
  State<ProductSettingsTab> createState() => _ProductSettingsTabState();
}

class _ProductSettingsTabState extends State<ProductSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _addProduct() {
    if (_formKey.currentState!.validate()) {
      context.read<ProductBloc>().add(
        CreateNewProduct(
          name: _nameController.text.trim(),
          sku: _skuController.text.trim(),
          price: double.tryParse(_priceController.text) ?? 0,
        ),
      );
      _nameController.clear();
      _skuController.clear();
      _priceController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductCreated) {
          context.read<ProductBloc>().add(LoadActiveProducts());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil ditambahkan')),
          );
        } else if (state is ProductError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Produk',
                      prefixIcon: Icon(Icons.inventory_2),
                    ),
                    validator: (value) => Validators.validateRequired(value, 'Nama Produk'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _skuController,
                    decoration: const InputDecoration(
                      labelText: 'SKU',
                      prefixIcon: Icon(Icons.tag),
                    ),
                    validator: (value) => Validators.validateRequired(value, 'SKU'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga Default',
                      prefixText: 'Rp ',
                      prefixIcon: Icon(Icons.money),
                    ),
                    validator: (value) => Validators.validatePositiveNumber(value, 'Harga Default'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addProduct,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Tambah Produk'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ProductsLoaded) {
                  if (state.products.isEmpty) {
                    return const Center(
                      child: Text('Belum ada produk'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.inventory_2),
                        ),
                        title: Text(product.name),
                        subtitle: Text(
                          'SKU: ${product.sku} | Rp ${product.price.toInt()}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () {
                            context.read<ProductBloc>().add(
                              SoftDeleteProductEvent(id: product.id),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SpgSettingsTab extends StatefulWidget {
  const SpgSettingsTab({super.key});

  @override
  State<SpgSettingsTab> createState() => _SpgSettingsTabState();
}

class _SpgSettingsTabState extends State<SpgSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addSpg() {
    if (_formKey.currentState!.validate()) {
      context.read<SpgBloc>().add(
        CreateNewSpq(name: _nameController.text.trim()),
      );
      _nameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpgBloc, SpgState>(
      listener: (context, state) {
        if (state is SpqCreated) {
          context.read<SpgBloc>().add(LoadActiveSpqs());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SPG berhasil ditambahkan')),
          );
        } else if (state is SpgError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama SPG',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) => Validators.validateRequired(value, 'Nama SPG'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addSpg,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Tambah SPG'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: BlocBuilder<SpgBloc, SpgState>(
              builder: (context, state) {
                if (state is SpgLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SpqsLoaded) {
                  if (state.spqs.isEmpty) {
                    return const Center(
                      child: Text('Belum ada SPG'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.spqs.length,
                    itemBuilder: (context, index) {
                      final spg = state.spqs[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(spg.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () {
                            context.read<SpgBloc>().add(
                              SoftDeleteSpqEvent(id: spg.id),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SpbSettingsTab extends StatefulWidget {
  const SpbSettingsTab({super.key});

  @override
  State<SpbSettingsTab> createState() => _SpbSettingsTabState();
}

class _SpbSettingsTabState extends State<SpbSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addSpb() {
    if (_formKey.currentState!.validate()) {
      context.read<SpbBloc>().add(
        CreateSpbEvent(name: _nameController.text.trim()),
      );
      _nameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SpbBloc, SpbState>(
      listener: (context, state) {
        if (state is SpbCreated) {
          context.read<SpbBloc>().add(LoadAllSpbs());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SPB berhasil ditambahkan')),
          );
        } else if (state is SpbDeleted) {
          context.read<SpbBloc>().add(LoadAllSpbs());
        } else if (state is SpbError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama SPB',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) => Validators.validateRequired(value, 'Nama SPB'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addSpb,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Tambah SPB'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: BlocBuilder<SpbBloc, SpbState>(
              builder: (context, state) {
                if (state is SpbLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SpbsLoaded) {
                  final spbs = state.spbs;
                  if (spbs.isEmpty) {
                    return const Center(
                      child: Text('Belum ada SPB'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: spbs.length,
                    itemBuilder: (context, index) {
                      final spb = spbs[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(spb.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: () {
                            context.read<SpbBloc>().add(
                              DeleteSpbEvent(spbId: spb.id),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}