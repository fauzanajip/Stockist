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
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SYSTEM PROTOCOL',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
              ),
              Text(
                'INITIALIZE NEW MISSION',
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader(context, 'MISSION IDENTIFICATION'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'MISSION NAME',
                    labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                    hintText: 'CONTOH: JAKARTA_DEPLOYMENT_2026',
                    hintStyle: TextStyle(color: AppColors.onSurface.withOpacity(0.2), fontSize: 14),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLowest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: AppColors.surfaceContainerHigh),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'MISSION NAME REQUIRED';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                _buildSectionHeader(context, 'DEPLOYMENT SCHEDULE'),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(primary: AppColors.primary),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      border: Border.all(color: AppColors.surfaceContainerHigh),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_note_outlined, color: AppColors.primary),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TARGET DATE',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant),
                            ),
                            Text(
                              app_formatters.Formatters.formatDate(_selectedDate).toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.swap_vert_rounded, color: AppColors.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text(
                            'EXECUTE INITIALIZATION',
                            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String label) {
    return Row(
      children: [
        Container(width: 4, height: 12, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
