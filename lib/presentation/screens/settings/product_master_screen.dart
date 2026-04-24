import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/product_entity.dart';
import '../../blocs/product_bloc/product_bloc.dart';
import '../../blocs/product_bloc/product_event.dart';
import '../../blocs/product_bloc/product_state.dart';

class ProductMasterScreen extends StatefulWidget {
  const ProductMasterScreen({super.key});

  @override
  State<ProductMasterScreen> createState() => _ProductMasterScreenState();
}

class _ProductMasterScreenState extends State<ProductMasterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadActiveProducts());
  }

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
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DATABASE SYSTEM',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
            ),
            Text(
              'MASTER ASSET REGISTRY',
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
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductCreated) {
            context.read<ProductBloc>().add(LoadActiveProducts());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ASSET REGISTERED: SUCCESS')),
            );
          }
          if (state is ProductUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ASSET UPDATED: SUCCESS')),
            );
          }
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: AppColors.surfaceContainerLowest,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      decoration: _buildInputDecoration('ASSET NAME', Icons.inventory_2_outlined),
                      validator: (value) => Validators.validateRequired(value, 'ASSET NAME'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _skuController,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                            decoration: _buildInputDecoration('SKU_ID', Icons.tag_outlined),
                            validator: (value) => Validators.validateRequired(value, 'SKU_ID'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                            decoration: _buildInputDecoration('BASE_VALUE', Icons.payments_outlined),
                            validator: (value) => Validators.validatePositiveNumber(value, 'VALUE'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _addProduct,
                        icon: const Icon(Icons.add_box_outlined, size: 18),
                        label: const Text('REGISTER NEW ASSET', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(height: 1, color: AppColors.surfaceContainerHigh),
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  if (state is ProductsLoaded) {
                    if (state.products.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            border: Border.all(color: AppColors.surfaceContainerHigh),
                          ),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name.toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'SKU: ${product.sku} | VAL: Rp ${product.price.toInt()}'.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurfaceVariant,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit_note_outlined, color: AppColors.primary, size: 20),
                                onPressed: () => _showEditBottomSheet(product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.error, size: 20),
                                onPressed: () => _confirmDelete(product),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5),
      prefixIcon: Icon(icon, size: 16),
      filled: true,
      fillColor: AppColors.surface,
      border: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide.none),
      enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide.none),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.primary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            'NO ASSETS REGISTERED'.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ProductEntity product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('DELETE ${product.sku}?'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text('TERMINATE ASSET REGISTRY FOR ${product.name.toUpperCase()}?', style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ABORT', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProductBloc>().add(
                SoftDeleteProductEvent(id: product.id),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            child: const Text('CONFIRM TERMINATE'),
          ),
        ],
      ),
    );
  }

  void _showEditBottomSheet(ProductEntity product) {
    final nameController = TextEditingController(text: product.name);
    final skuController = TextEditingController(text: product.sku);
    final priceController = TextEditingController(text: product.price.toString());
    final editFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: editFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit_note_outlined, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        'REVISE ASSET DATA',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  TextFormField(
                    controller: nameController,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                    decoration: _buildInputDecoration('ASSET NAME', Icons.inventory_2_outlined),
                    validator: (value) => Validators.validateRequired(value, 'ASSET NAME'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: skuController,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                          decoration: _buildInputDecoration('SKU_ID', Icons.tag_outlined),
                          validator: (value) => Validators.validateRequired(value, 'SKU_ID'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                          decoration: _buildInputDecoration('BASE_VALUE', Icons.payments_outlined),
                          validator: (value) => Validators.validatePositiveNumber(value, 'VALUE'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (editFormKey.currentState!.validate()) {
                          final updatedProduct = product.copyWith(
                            name: nameController.text.trim(),
                            sku: skuController.text.trim(),
                            price: double.tryParse(priceController.text) ?? 0,
                          );
                          context.read<ProductBloc>().add(UpdateProduct(product: updatedProduct));
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        elevation: 0,
                      ),
                      child: const Text('COMMIT CHANGES', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
