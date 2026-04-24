import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/event_bloc/event_bloc.dart';
import '../../blocs/event_bloc/event_event.dart';
import '../../../core/constants/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              'SYSTEM CONFIGURATION',
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildCategory(context, 'OPERATIONAL PROTOCOLS'),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            icon: Icons.add_circle_outline,
            title: 'INITIALIZE MISSION',
            subtitle: 'Buat event, produk, dan SPG baru',
            color: AppColors.primary,
            onTap: () => context.pushNamed('create_event'),
          ),
          const SizedBox(height: 8),
          _buildMenuTile(
            context,
            icon: Icons.radar_outlined,
            title: 'MISSION DEPLOYMENT',
            subtitle: 'Pilih event utama di Home Screen',
            color: AppColors.secondary,
            onTap: () => context.pushNamed('event_focus'),
          ),
          const SizedBox(height: 8),
          _buildMenuTile(
            context,
            icon: Icons.save_as_outlined,
            title: 'DATA ARCHIVE',
            subtitle: 'Backup & Restore database sistem',
            color: AppColors.primary,
            onTap: () => context.pushNamed('backup'),
          ),
          const SizedBox(height: 32),
          _buildCategory(context, 'CORE MASTER ASSETS'),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            icon: Icons.inventory_2_outlined,
            title: 'PRODUCT DATABASE',
            subtitle: 'Kelola database produk default',
            color: AppColors.onSurfaceVariant,
            onTap: () => context.pushNamed('product_master'),
          ),
          const SizedBox(height: 8),
          _buildMenuTile(
            context,
            icon: Icons.groups_3_outlined,
            title: 'SPG PERSONNEL',
            subtitle: 'Daftar personel SPG terdaftar',
            color: AppColors.onSurfaceVariant,
            onTap: () => context.pushNamed('spg_master'),
          ),
          const SizedBox(height: 8),
          _buildMenuTile(
            context,
            icon: Icons.badge_outlined,
            title: 'SUPERVISOR ROSTER',
            subtitle: 'Manajemen supervisor (SPB)',
            color: AppColors.onSurfaceVariant,
            onTap: () => context.pushNamed('spb_master'),
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.05),
              border: Border.all(color: AppColors.error.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'HIGH-LEVEL OVERRIDE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'SYSTEM HARD RESET',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Purge all mission data, transactions, and master records from local storage. Non-reversible.',
                  style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showResetConfirmation(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: const Text('EXECUTE HARD RESET', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'STOCKIST OS V1.0.42_STABLE',
              style: TextStyle(
                fontSize: 9,
                color: AppColors.onSurface.withOpacity(0.3),
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text(
          'CONFIRM HARD RESET',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        content: const Text(
          'ARE YOU ABSOLUTELY SURE? This protocol will destroy all mission data, inventory logs, and personnel records without recovery.',
          style: TextStyle(fontSize: 12, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<EventBloc>().add(ResetAllData());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PURGE COMPLETE: SYSTEM WIPED')),
              );
              context.goNamed('home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('PURGE SYSTEM'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String label) {
    return Row(
      children: [
        Container(width: 4, height: 12, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.surfaceContainerHigh),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle.toUpperCase(),
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
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.onSurfaceVariant,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
