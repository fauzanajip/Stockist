import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/validators.dart';
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
      appBar: AppBar(title: const Text('Master SPB')),
      body: BlocListener<SpbBloc, SpbState>(
        listener: (context, state) {
          if (state is SpbCreated) {
            context.read<SpbBloc>().add(LoadAllSpbs());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SPB berhasil ditambahkan')),
            );
          } else if (state is SpbDeleted) {
            context.read<SpbBloc>().add(LoadAllSpbs());
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
                        prefixIcon: Icon(Icons.person_pin_outlined),
                      ),
                      validator: (value) =>
                          Validators.validateRequired(value, 'Nama SPB'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _addSpb,
                      icon: const Icon(Icons.add),
                      label: const Text('TAMBAH SPB'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
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
                    if (state.spbs.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: state.spbs.length,
                      itemBuilder: (context, index) {
                        final spb = state.spbs[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: const Icon(Icons.person_pin, color: AppColors.primary, size: 20),
                            ),
                            title: Text(spb.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              onPressed: () => _confirmDelete(spb),
                            ),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_pin_outlined, size: 64, color: AppColors.onSurfaceVariant),
          SizedBox(height: 16),
          Text('Belum ada SPB', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmDelete(spb) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus SPB?'),
        content: Text('Yakin ingin menghapus ${spb.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('BATAL')),
          TextButton(
            onPressed: () {
              context.read<SpbBloc>().add(DeleteSpbEvent(spbId: spb.id));
              Navigator.pop(context);
            },
            child: const Text('HAPUS', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
