import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart' as app_formatters;
import '../../blocs/event_bloc/event_bloc.dart';
import '../../blocs/event_bloc/event_event.dart';
import '../../blocs/event_bloc/event_state.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createEvent() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      context.read<EventBloc>().add(
        CreateNewEvent(name: _nameController.text.trim(), date: _selectedDate),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventState>(
      listener: (context, state) {
        if (state is EventCreated) {
          context.goNamed('home');
        } else if (state is EventError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Event')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Event',
                    hintText: 'Contoh: Event Jakarta 2026',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama event tidak boleh kosong';
                    }
                    if (value.trim().length < 3) {
                      return 'Nama event minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: AppColors.secondary,
                    ),
                    title: const Text('Tanggal Event'),
                    subtitle: Text(
                      app_formatters.Formatters.formatDate(_selectedDate),
                      style: const TextStyle(color: AppColors.onSurface),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 30),
                        ),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createEvent,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
