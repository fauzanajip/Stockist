import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/validators.dart';
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
      appBar: AppBar(title: const Text('Master SPG')),
      body: BlocListener<SpgBloc, SpgState>(
        listener: (context, state) {
          if (state is SpqCreated) {
            context.read<SpgBloc>().add(LoadActiveSpqs());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SPG berhasil ditambahkan')),
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
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          Validators.validateRequired(value, 'Nama SPG'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _addSpg,
                      icon: const Icon(Icons.add),
                      label: const Text('TAMBAH SPG'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
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
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: state.spqs.length,
                      itemBuilder: (context, index) {
                        final spg = state.spqs[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              spg.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () => _confirmDelete(spg),
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
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.onSurfaceVariant,
          ),
          SizedBox(height: 16),
          Text('Belum ada SPG', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmDelete(spg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus SPG?'),
        content: Text('Yakin ingin menghapus ${spg.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () {
              context.read<SpgBloc>().add(SoftDeleteSpqEvent(id: spg.id));
              Navigator.pop(context);
            },
            child: const Text(
              'HAPUS',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
