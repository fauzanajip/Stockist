import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/spg_entity.dart';
import '../../blocs/spg_bloc/spg_bloc.dart';
import '../../blocs/spg_bloc/spg_event.dart';
import '../../blocs/spg_bloc/spg_state.dart';

import 'package:file_picker/file_picker.dart';
import '../../../core/utils/excel_import_service.dart';
import '../../../core/utils/downloader/downloader.dart';

class SpgMasterScreen extends StatefulWidget {
  const SpgMasterScreen({super.key});

  @override
  State<SpgMasterScreen> createState() => _SpgMasterScreenState();
}

class _SpgMasterScreenState extends State<SpgMasterScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _nameControllers = [TextEditingController()];
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<SpgBloc>().add(LoadActiveSpqs());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addSpg() {
    if (_formKey.currentState!.validate()) {
      final List<String> names = [];
      for (var controller in _nameControllers) {
        if (controller.text.trim().isNotEmpty) {
          names.add(controller.text.trim());
        }
      }
      
      if (names.isNotEmpty) {
        context.read<SpgBloc>().add(CreateMultipleSpqs(names: names));
      }

      setState(() {
        for (var controller in _nameControllers) {
          controller.dispose();
        }
        _nameControllers.clear();
        _nameControllers.add(TextEditingController());
        _listKey = GlobalKey<AnimatedListState>();
      });
    }
  }


  void _downloadTemplate() {
    final bytes = ExcelImportService.generateNameOnlyTemplate('PERSONNEL_NAME');
    if (bytes != null) {
      downloadFile(
        bytes,
        'spg_template.xlsx',
      );
    }
  }

  void _importExcel() async {
    final result = await ExcelImportService.pickExcelFile();
    if (result != null) {
      final names = await ExcelImportService.parseNameOnlyExcel(result.files.single, 'PERSONNEL_NAME');
      if (names.isNotEmpty) {
        for (final name in names) {
          final newController = TextEditingController(text: name);
          _nameControllers.add(newController);
          _listKey.currentState?.insertItem(
            _nameControllers.length - 1,
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

  void _addRepeaterRow() {
    _nameControllers.add(TextEditingController());
    _listKey.currentState?.insertItem(
      _nameControllers.length - 1,
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

  void _removeRepeaterRow(TextEditingController controller) {
    if (_nameControllers.length > 1) {
      final index = _nameControllers.indexOf(controller);
      if (index != -1) {
        _listKey.currentState?.removeItem(
          index,
          (context, animation) => _buildRowItem(controller, index + 1, true, animation),
          duration: const Duration(milliseconds: 300),
        );
        _nameControllers.removeAt(index);
        Future.delayed(const Duration(milliseconds: 350), () {
          controller.dispose();
        });
      }
    }
  }

  Widget _buildRowItem(TextEditingController controller, int rowNumber, bool isRemovable, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12.0),
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
                children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    decoration: _buildInputDecoration('PERSONNEL NAME', Icons.person_add_alt_1_outlined),
                    validator: (value) => Validators.validateRequired(value, 'PERSONNEL NAME'),
                  ),
                ),
                if (isRemovable)
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                    onPressed: () => _removeRepeaterRow(controller),
                  ),
                ]
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
      body: BlocListener<SpgBloc, SpgState>(
        listener: _spgBlocListener,
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
        body: BlocListener<SpgBloc, SpgState>(
          listener: _spgBlocListener,
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

  void _spgBlocListener(BuildContext context, SpgState state) {
    if (state is SpqCreated) {
      context.read<SpgBloc>().add(LoadActiveSpqs());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PERSONNEL REGISTERED: SUCCESS')),
      );
    }
    if (state is SpgUpdated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PERSONNEL UPDATED: SUCCESS')),
      );
    }
    if (state is SpgError) {
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
            'PERSONNEL LOGS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
          ),
          Text(
            'FIELD PERSONNEL DATABASE',
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
                Tab(text: 'RECORDS'),
                Tab(text: 'ADD PERSONNEL'),
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
                'ENLIST NEW PERSONNEL',
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
                initialItemCount: _nameControllers.length,
                itemBuilder: (context, index, animation) {
                  return _buildRowItem(_nameControllers[index], index + 1, _nameControllers.length > 1, animation);
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
                    onPressed: _addSpg,
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
    return BlocBuilder<SpgBloc, SpgState>(
      builder: (context, state) {
        if (state is SpgLoading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (state is SpqsLoaded) {
          if (state.spqs.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: state.spqs.length,
            itemBuilder: (context, index) {
              final spg = state.spqs[index];
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
                            spg.name.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'STATUS: ACTIVE_DUTY',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_document, color: AppColors.primary, size: 20),
                      onPressed: () => _showEditBottomSheet(spg),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_remove_outlined, color: AppColors.error, size: 20),
                      onPressed: () => _confirmDelete(spg),
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
          const Icon(Icons.no_accounts_outlined, size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'NO PERSONNEL RECORDS FOUND'.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(SpgEntity spg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('TERMINATE PERSONNEL?'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text('REMOVE ${spg.name.toUpperCase()} FROM ACTIVE SERVICE DATABASE?', style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ABORT', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SpgBloc>().add(SoftDeleteSpqEvent(id: spg.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            child: const Text('TERMINATE RECORDS'),
          ),
        ],
      ),
    );
  }

  void _showEditBottomSheet(SpgEntity spg) {
    final nameController = TextEditingController(text: spg.name);
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
                      const Icon(Icons.edit_document, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        'REVISE PERSONNEL PROTOCOL',
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
                    decoration: _buildInputDecoration('PERSONNEL NAME', Icons.person_outline),
                    validator: (value) => Validators.validateRequired(value, 'PERSONNEL NAME'),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (editFormKey.currentState!.validate()) {
                          final updatedSpg = spg.copyWith(
                            name: nameController.text.trim(),
                          );
                          context.read<SpgBloc>().add(UpdateSpgEvent(spg: updatedSpg));
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
