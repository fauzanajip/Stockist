import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart' as app_formatters;
import '../../blocs/event_bloc/event_bloc.dart';
import '../../blocs/event_bloc/event_event.dart';
import '../../blocs/event_bloc/event_state.dart';

class EventFocusScreen extends StatefulWidget {
  const EventFocusScreen({super.key});

  @override
  State<EventFocusScreen> createState() => _EventFocusScreenState();
}

class _EventFocusScreenState extends State<EventFocusScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EventBloc>().add(LoadAllEvents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fokus Event'),
      ),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EventsLoaded) {
            final events = state.events;

            if (events.isEmpty) {
              return const Center(child: Text('Belum ada event.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final isActive = event.isActive;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: isActive
                        ? const BorderSide(color: AppColors.primary, width: 2)
                        : BorderSide.none,
                  ),
                  child: InkWell(
                    onTap: () {
                      context
                          .read<EventBloc>()
                          .add(SetEventActive(id: event.id));
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.onSurface.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isActive ? Icons.star : Icons.star_border,
                              color: isActive ? Colors.white : AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  app_formatters.Formatters.formatDate(event.date),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isActive)
                            const Icon(Icons.check_circle, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Klik pada event untuk menjadikannya Dashboard utama di Home Screen.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onSurface.withOpacity(0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}
