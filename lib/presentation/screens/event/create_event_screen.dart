import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/validators.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Event'),
      ),
      body: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Event "${state.event.name}" berhasil dibuat'),
                backgroundColor: AppColors.success,
              ),
            );
            context.goNamed('event_setup', pathParameters: {
              'eventId': state.event.id,
            });
          } else if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Padding(
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
                    prefixIcon: Icon(Icons.event),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => Validators.validateMinLength(value, 3, 'Nama event'),
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today, color: AppColors.secondary),
                    title: const Text('Tanggal Event'),
                    subtitle: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        locale: const Locale('id', 'ID'),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Status: OPEN (aktif)',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                BlocBuilder<EventBloc, EventState>(
                  builder: (context, state) {
                    final isLoading = state is EventLoading;
                    return ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<EventBloc>().add(
                                  CreateNewEvent(
                                    name: _nameController.text.trim(),
                                    date: _selectedDate,
                                  ),
                                );
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Buat Event'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
