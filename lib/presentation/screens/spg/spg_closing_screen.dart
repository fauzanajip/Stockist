import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

class SpgClosingScreen extends StatelessWidget {
  final String eventId;
  final String spgId;

  const SpgClosingScreen({super.key, required this.eventId, required this.spgId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Closing SPG'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.playlist_add_check, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Closing Screen',
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
