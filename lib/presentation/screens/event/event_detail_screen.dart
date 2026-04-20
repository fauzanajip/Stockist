import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';

class EventDetailScreen extends StatelessWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.pushNamed('event_setup', pathParameters: {
              'eventId': eventId,
            }),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Actions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.pushNamed('spg_list', pathParameters: {
                        'eventId': eventId,
                      }),
                      icon: const Icon(Icons.people),
                      label: const Text('Manage SPG'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Export to Excel
                      },
                      icon: const Icon(Icons.file_download),
                      label: const Text('Export Excel'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
