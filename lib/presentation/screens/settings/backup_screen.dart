import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RECOVERY PROTOCOL',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
            ),
            Text(
              'SYSTEM DATA ARCHIVE',
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border.all(color: AppColors.surfaceContainerHigh),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.archive_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      const Text(
                        'DATA EXFILTRATION',
                        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'EXPORT SYSTEM DATABASE TO ENCRYPTED JSON ARCHIVE. FORWARD TO SECURE EXTERNAL REPOSITORIES.',
                    style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, height: 1.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement backup functionality
                      },
                      icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                      label: const Text('EXECUTE EXPORT', style: TextStyle(fontWeight: FontWeight.w900)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                border: Border.all(color: AppColors.surfaceContainerHigh),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.unarchive_outlined, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 12),
                      const Text(
                        'DATA INFILTRATION',
                        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'RE-ESTABLISH MISSION DATA FROM EXTERNAL ARCHIVE. EXISTING LOCAL TELEMETRY WILL BE OVERWRITTEN.',
                    style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, height: 1.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement restore functionality
                      },
                      icon: const Icon(Icons.file_open_outlined, size: 18),
                      label: const Text('IMPORT ARCHIVE', style: TextStyle(fontWeight: FontWeight.w900)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.secondary),
                        foregroundColor: AppColors.secondary,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: Text(
                'LOG_ENCRYPTION_LINK: AES-256V2_ACTIVE',
                style: TextStyle(
                  fontSize: 8,
                  color: AppColors.onSurfaceVariant.withOpacity(0.5),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
