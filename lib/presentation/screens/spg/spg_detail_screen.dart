import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';

class SpgDetailScreen extends StatelessWidget {
  final String eventId;
  final String spgId;

  const SpgDetailScreen({super.key, required this.eventId, required this.spgId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPG Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActionButton(
              context,
              icon: Icons.add_box,
              label: 'Distribusi Awal',
              color: AppColors.primary,
              route: 'initial_distribution',
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              icon: Icons.add_circle_outline,
              label: 'Tambah Stok',
              color: AppColors.success,
              route: 'topup',
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              icon: Icons.refresh,
              label: 'Retur Stok',
              color: AppColors.warning,
              route: 'return',
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              icon: Icons.bar_chart,
              label: 'Update Sales',
              color: AppColors.secondary,
              route: 'sales_input',
            ),
            const SizedBox(height: 12),
            _buildActionButton(
              context,
              icon: Icons.attach_money,
              label: 'Input Cash',
              color: AppColors.tertiary,
              route: 'cash_input',
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.pushNamed('spg_closing', pathParameters: {
                'eventId': eventId,
                'spgId': spgId,
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerHigh,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Closing SPG', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required String route,
  }) {
    return ElevatedButton(
      onPressed: () => context.pushNamed(route, pathParameters: {
        'eventId': eventId,
        'spgId': spgId,
      }),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
