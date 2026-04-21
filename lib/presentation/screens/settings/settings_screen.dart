import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCategory(context, 'OPERASIONAL'),
          _buildMenuTile(
            context,
            icon: Icons.add_circle_outline,
            title: 'Tambah Event Baru',
            subtitle: 'Buat event, produk, dan SPG baru',
            color: AppColors.primary,
            onTap: () => context.pushNamed('create_event'),
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            icon: Icons.star_outline,
            title: 'Fokus Event',
            subtitle: 'Pilih event utama di Home Screen',
            color: AppColors.secondary,
            onTap: () => context.pushNamed('event_focus'),
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            icon: Icons.backup_outlined,
            title: 'Backup & Restore',
            subtitle: 'Amankan data Anda ke file',
            color: AppColors.primary,
            onTap: () => context.pushNamed('backup'),
          ),
          const SizedBox(height: 32),
          _buildCategory(context, 'MASTER DATA'),
          _buildMenuTile(
            context,
            icon: Icons.inventory_2_outlined,
            title: 'Daftar Produk',
            subtitle: 'Kelola database produk default',
            color: AppColors.onSurfaceVariant,
            onTap: () => context.pushNamed('product_master'),
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            icon: Icons.people_outline,
            title: 'Database SPG',
            subtitle: 'Daftar personel SPG',
            color: AppColors.onSurfaceVariant,
            onTap: () => context.pushNamed('spg_master'),
          ),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            icon: Icons.person_pin_outlined,
            title: 'Daftar SPB',
            subtitle: 'Manajemen supervisor (SPB)',
            color: AppColors.onSurfaceVariant,
            onTap: () => context.pushNamed('spb_master'),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Stockist App v2.4',
              style: TextStyle(
                fontSize: 10,
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

  Widget _buildCategory(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: AppColors.onSurfaceVariant,
          letterSpacing: 1.5,
        ),
      ),
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
    return Material(
      color: AppColors.surfaceContainer,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
