import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/spb_entity.dart';
import '../../blocs/spb_bloc/spb_bloc.dart';
import '../../blocs/spb_bloc/spb_event.dart';
import '../../blocs/spb_bloc/spb_state.dart';

class SpbMasterScreen extends StatefulWidget {
  const SpbMasterScreen({super.key});

  @override
  State<SpbMasterScreen> createState() => _SpbMasterScreenState();
}

class _SpbMasterScreenState extends State<SpbMasterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SpbBloc>().add(LoadAllSpbs());
  }

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
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'COMMAND HIERARCHY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
            ),
            Text(
              'FIELD SUPERVISOR ROSTER',
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
      body: BlocListener<SpbBloc, SpbState>(
        listener: (context, state) {
          if (state is SpbCreated) {
            context.read<SpbBloc>().add(LoadAllSpbs());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SUPERVISOR ENLISTED: SUCCESS')),
            );
          } else if (state is SpbUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SUPERVISOR UPDATED: SUCCESS')),
            );
          } else if (state is SpbDeleted) {
            context.read<SpbBloc>().add(LoadAllSpbs());
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
                      decoration: _buildInputDecoration('SUPERVISOR NAME', Icons.person_pin_outlined),
                      validator: (value) => Validators.validateRequired(value, 'SUPERVISOR NAME'),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _addSpb,
                        icon: const Icon(Icons.verified_user_outlined, size: 18),
                        label: const Text('ENLIST SUPERVISOR', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
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
              child: BlocBuilder<SpbBloc, SpbState>(
                builder: (context, state) {
                  if (state is SpbLoading) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  }
                  if (state is SpbsLoaded) {
                    if (state.spbs.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      itemCount: state.spbs.length,
                      itemBuilder: (context, index) {
                        final spb = state.spbs[index];
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
                                    spb.name.toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'RANK: FIELD_SUPERVISOR',
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
                                icon: const Icon(Icons.edit_note_outlined, color: AppColors.primary, size: 20),
                                onPressed: () => _showEditBottomSheet(spb),
                              ),
                              IconButton(
                                icon: const Icon(Icons.person_remove_outlined, color: AppColors.error, size: 20),
                                onPressed: () => _confirmDelete(spb),
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
          const Icon(Icons.supervisor_account_outlined, size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'NO SUPERVISOR ROSTER DATA'.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(SpbEntity spb) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('REMOVE SUPERVISOR?'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text('DECOMMISSION ${spb.name.toUpperCase()} FROM COMMAND HIERARCHY?', style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ABORT', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SpbBloc>().add(DeleteSpbEvent(spbId: spb.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            child: const Text('CONFIRM REMOVAL'),
          ),
        ],
      ),
    );
  }

  void _showEditBottomSheet(SpbEntity spb) {
    final nameController = TextEditingController(text: spb.name);
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
                        'REVISE SUPERVISOR PROTOCOL',
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
                    decoration: _buildInputDecoration('SUPERVISOR NAME', Icons.person_pin_outlined),
                    validator: (value) => Validators.validateRequired(value, 'SUPERVISOR NAME'),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (editFormKey.currentState!.validate()) {
                          final updatedSpb = spb.copyWith(
                            name: nameController.text.trim(),
                          );
                          context.read<SpbBloc>().add(UpdateSpbEvent(spb: updatedSpb));
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
