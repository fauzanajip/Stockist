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
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CONTROL PANEL',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
            ),
            Text(
              'ACTIVE MISSION SELECTION',
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
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          if (state is EventsLoaded) {
            final events = state.events;

            if (events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.dangerous_outlined, color: AppColors.onSurfaceVariant, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'NO REGISTERED MISSIONS FOUND'.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                final isActive = event.isActive;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.surfaceContainerHigh,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      context.read<EventBloc>().add(
                        SetEventActive(id: event.id),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            isActive ? Icons.hub_outlined : Icons.hub_outlined,
                            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.name.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'TIMESTAMP: ${app_formatters.Formatters.formatDate(event.date).toUpperCase()}',
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
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: const BoxDecoration(color: AppColors.primary),
                              child: const Text(
                                'ACTIVE_LINK',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
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
      bottomNavigationBar: Container(
        color: AppColors.surfaceContainerLowest,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: const Text(
          'SELECT PROTOCOL TO ESTABLISH MAIN DASHBOARD TELEMETRY LINK.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
