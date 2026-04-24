import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/spg_entity.dart';
import '../../blocs/spg_bloc/spg_bloc.dart';
import '../../blocs/spg_bloc/spg_event.dart';
import '../../blocs/spg_bloc/spg_state.dart';

class SpgMasterScreen extends StatefulWidget {
  const SpgMasterScreen({super.key});

  @override
  State<SpgMasterScreen> createState() => _SpgMasterScreenState();
}

class _SpgMasterScreenState extends State<SpgMasterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SpgBloc>().add(LoadActiveSpqs());
  }

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
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.surfaceContainerHigh, height: 1),
        ),
      ),
      body: BlocListener<SpgBloc, SpgState>(
        listener: (context, state) {
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
                      decoration: _buildInputDecoration('PERSONNEL NAME', Icons.person_add_alt_1_outlined),
                      validator: (value) => Validators.validateRequired(value, 'PERSONNEL NAME'),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _addSpg,
                        icon: const Icon(Icons.shield_outlined, size: 18),
                        label: const Text('ENLIST NEW PERSONNEL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
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
              child: BlocBuilder<SpgBloc, SpgState>(
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
                              Column(
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
                              const Spacer(),
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
