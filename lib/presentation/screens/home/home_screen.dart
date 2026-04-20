import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../blocs/event_bloc/event_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stockist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.backup),
            onPressed: () => context.pushNamed('backup'),
          ),
        ],
      ),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EventsLoaded) {
            if (state.events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_note, size: 64, color: AppColors.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada event',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Klik + untuk membuat event baru',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.events.length,
              itemBuilder: (context, index) {
                final event = state.events[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => context.pushNamed('event_detail', pathParameters: {
                      'eventId': event.id,
                    }),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  event.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: event.status == EventStatus.open 
                                      ? AppColors.primary.withOpacity(0.2)
                                      : AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  event.status == EventStatus.open ? 'OPEN' : 'CLOSED',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: event.status == EventStatus.open 
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Text(
                                Formatters.formatDayDate(event.date),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (state is EventError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('create_event'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
