import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/formatters.dart';

class EventSetupScreen extends StatelessWidget {
  final String eventId;

  const EventSetupScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2, color: AppColors.primary),
                ),
                title: const Text('Assign Produk'),
                subtitle: const Text('Pilih produk yang akan dijual'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Navigate to product selection
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.people, color: AppColors.secondary),
                ),
                title: const Text('Assign SPG'),
                subtitle: const Text('Pilih SPG yang aktif di event ini'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Navigate to SPG selection
                },
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                // TODO: Validate setup and navigate to event detail
              },
              child: const Text('Save Setup'),
            ),
          ],
        ),
      ),
    );
  }
}
