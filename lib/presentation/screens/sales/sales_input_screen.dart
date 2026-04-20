import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

class SalesInputScreen extends StatelessWidget {
  final String eventId;
  final String spgId;

  const SalesInputScreen({super.key, required this.eventId, required this.spgId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Sales'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 64, color: AppColors.secondary),
            const SizedBox(height: 16),
            Text(
              'Sales Input',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Event: $eventId\nSPG: $spgId',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
