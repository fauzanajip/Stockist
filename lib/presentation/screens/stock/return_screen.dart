import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

class ReturnScreen extends StatelessWidget {
  final String eventId;
  final String spgId;

  const ReturnScreen({super.key, required this.eventId, required this.spgId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retur Stok'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, size: 64, color: AppColors.warning),
            const SizedBox(height: 16),
            Text(
              'Return Stock',
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
