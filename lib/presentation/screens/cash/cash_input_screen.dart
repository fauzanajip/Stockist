import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

class CashInputScreen extends StatelessWidget {
  final String eventId;
  final String spgId;

  const CashInputScreen({super.key, required this.eventId, required this.spgId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Cash'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.attach_money, size: 64, color: AppColors.tertiary),
            const SizedBox(height: 16),
            Text(
              'Cash Input',
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
