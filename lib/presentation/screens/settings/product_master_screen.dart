import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/product_entity.dart';
import '../../blocs/product_bloc/product_bloc.dart';
import '../../blocs/product_bloc/product_event.dart';
import '../../blocs/product_bloc/product_state.dart';

import 'package:file_picker/file_picker.dart';
import '../../../core/utils/excel_import_service.dart';
import '../../../core/utils/downloader/downloader.dart';

class ProductMasterScreen extends StatefulWidget {
  const ProductMasterScreen({super.key});

  @override
  State<ProductMasterScreen> createState() => _ProductMasterScreenState();
}

class ProductFormControllers {
  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final priceController = TextEditingController();

  void dispose() {
    nameController.dispose();
    skuController.dispose();
    priceController.dispose();
  }
}

class _ProductMasterScreenState extends State<ProductMasterScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<ProductFormControllers> _controllersList = [ProductFormControllers()];
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(LoadActiveProducts());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var controllers in _controllersList) {
      controllers.dispose();
    }
    super.dispose();
  }

  void _addProduct() {
    if (_formKey.currentState!.validate()) {
      final List<CreateNewProduct> products = [];
      for (var controllers in _controllersList) {
        if (controllers.nameController.text.trim().isNotEmpty) {
          products.add(
            CreateNewProduct(
              name: controllers.nameController.text.trim(),
              sku: controllers.skuController.text.trim(),
              price: double.tryParse(controllers.priceController.text) ?? 0,
            ),
          );
        }
      }
      
      if (products.isNotEmpty) {
        context.read<ProductBloc>().add(CreateMultipleProducts(products: products));
      }

      setState(() {
        for (var controllers in _controllersList) {
          controllers.dispose();
        }
        _controllersList.clear();
        _controllersList.add(ProductFormControllers());
        _listKey = GlobalKey<AnimatedListState>();
      });
    }
  }

  void _addRepeaterRow() {
    _controllersList.add(ProductFormControllers());
    _listKey.currentState?.insertItem(
      _controllersList.length - 1,
      duration: const Duration(milliseconds: 300),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _downloadTemplate() {
    final bytes = ExcelImportService.generateProductTemplate();
    if (bytes != null) {
      downloadFile(
        bytes,
        'product_template.xlsx',
      );
    }
  }

  void _importExcel() async {
    final result = await ExcelImportService.pickExcelFile();
    if (result != null) {
      final products = await ExcelImportService.parseProductExcel(result.files.single);
      if (products.isNotEmpty) {
        for (final p in products) {
          final newController = ProductFormControllers();
          newController.nameController.text = p['name'] ?? '';
          newController.skuController.text = p['sku'] ?? '';
          newController.priceController.text = (p['price'] as double).toInt().toString();

          _controllersList.add(newController);
          _listKey.currentState?.insertItem(
            _controllersList.length - 1,
            duration: const Duration(milliseconds: 300),
          );
        }

        Future.delayed(const Duration(milliseconds: 350), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  void _removeRepeaterRow(ProductFormControllers controllers) {
    if (_controllersList.length > 1) {
      final index = _controllersList.indexOf(controllers);
      if (index != -1) {
        _listKey.currentState?.removeItem(
          index,
          (context, animation) => _buildRowItem(controllers, index + 1, true, animation),
          duration: const Duration(milliseconds: 300),
        );
        _controllersList.removeAt(index);
        Future.delayed(const Duration(milliseconds: 350), () {
          controllers.dispose();
        });
      }
    }
  }

  Widget _buildRowItem(ProductFormControllers item, int rowNumber, bool isRemovable, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16.0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.surfaceContainerHighest),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ROW #$rowNumber', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 10, letterSpacing: 1)),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: item.nameController,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      decoration: _buildInputDecoration('ASSET NAME', Icons.inventory_2_outlined),
                      validator: (value) => Validators.validateRequired(value, 'ASSET NAME'),
                    ),
                  ),
                  if (isRemovable)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                      onPressed: () => _removeRepeaterRow(item),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: item.skuController,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      decoration: _buildInputDecoration('SKU_ID', Icons.tag_outlined),
                      validator: (value) => Validators.validateRequired(value, 'SKU_ID'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: item.priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      decoration: _buildInputDecoration('BASE_VALUE', Icons.payments_outlined),
                      validator: (value) => Validators.validatePositiveNumber(value, 'VALUE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildWebLayout(context);
        } else {
          return _buildMobileLayout(context);
        }
      },
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context),
      body: BlocListener<ProductBloc, ProductState>(
        listener: _productBlocListener,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildListSection(context)),
            Container(width: 1, color: AppColors.surfaceContainerHigh),
            Expanded(flex: 3, child: _buildFormSection(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: _buildAppBar(context, showTabs: true),
        body: BlocListener<ProductBloc, ProductState>(
          listener: _productBlocListener,
          child: TabBarView(
            children: [
              _buildListSection(context),
              _buildFormSection(context),
            ],
          ),
        ),
      ),
    );
  }

  void _productBlocListener(BuildContext context, ProductState state) {
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
    if (state is ProductError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, {bool showTabs = false}) {
    return AppBar(
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
      bottom: showTabs
          ? const TabBar(
              tabs: [
                Tab(text: 'REGISTRY'),
                Tab(text: 'ADD ASSETS'),
              ],
              indicatorColor: AppColors.primary,
              labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: AppColors.surfaceContainerHigh, height: 1),
            ),
    );
  }

  Widget _buildFormSection(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Container(
        padding: const EdgeInsets.all(20),
        color: AppColors.surfaceContainerLowest,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ADD NEW ASSETS',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                   OutlinedButton.icon(
                    onPressed: _downloadTemplate,
                    icon: const Icon(Icons.download_outlined, size: 16),
                    label: const Text('TEMPLATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurfaceVariant,
                      side: BorderSide(color: AppColors.surfaceContainerHighest),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _importExcel,
                    icon: const Icon(Icons.upload_file_outlined, size: 16),
                    label: const Text('IMPORT EXCEL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedList(
                key: _listKey,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                initialItemCount: _controllersList.length,
                itemBuilder: (context, index, animation) {
                  return _buildRowItem(_controllersList[index], index + 1, _controllersList.length > 1, animation);
                },
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _addRepeaterRow,
                    icon: const Icon(Icons.add, color: AppColors.primary, size: 16),
                    label: const Text('ADD ROW', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _addProduct,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('SAVE BATCH', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListSection(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
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
                    Expanded(
                      child: Column(
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
                    ),
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
