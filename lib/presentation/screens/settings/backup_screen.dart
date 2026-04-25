import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/utils/backup_service.dart';
import '../../blocs/event_bloc/event_bloc.dart';
import '../../blocs/event_bloc/event_event.dart';
import '../../blocs/product_bloc/product_bloc.dart';
import '../../blocs/product_bloc/product_event.dart';
import '../../blocs/spg_bloc/spg_bloc.dart';
import '../../blocs/spg_bloc/spg_event.dart';

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
                        'DATA_EXFILTRATION',
                        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'EXPORT SYSTEM DATABASE TO ENCRYPTED JSON ARCHIVE. FORWARD TO SECURE EXTERNAL REPOSITORIES.',
                    style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await BackupService.exportBackup();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('DATA_EXFILTRATION_COMPLETE: SUCCESS'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('EXPORT_ERROR: ${e.toString().toUpperCase()}')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                      label: const Text('EXECUTE_EXPORT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
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
                        'DATA_INFILTRATION',
                        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'RE-ESTABLISH MISSION DATA FROM EXTERNAL ARCHIVE. EXISTING LOCAL TELEMETRY WILL BE OVERWRITTEN.',
                    style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['json'],
                        );

                        if (result != null && result.files.single.path != null) {
                          final filePath = result.files.single.path!;
                          final fileName = result.files.single.name;

                          final confirmed = await _showConfirmDialog(context, fileName);
                          if (confirmed == true) {
                            try {
                              await BackupService.importBackup(filePath);

                              // Reload all blocs
                              context.read<EventBloc>().add(LoadAllEvents());
                              context.read<ProductBloc>().add(LoadAllProducts());
                              context.read<SpgBloc>().add(LoadAllSpqs());

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('DATA_INFILTRATION_COMPLETE: TELEMETRY RESTORED'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('IMPORT_ERROR: ${e.toString().toUpperCase()}')),
                                );
                              }
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.file_open_outlined, size: 18),
                      label: const Text('IMPORT_ARCHIVE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        side: const BorderSide(color: AppColors.secondary),
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

  static Future<bool?> _showConfirmDialog(BuildContext context, String fileName) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_outlined, color: AppColors.error, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'DATA_OVERRIDE_PROTOCOL',
                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 14, color: AppColors.error),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  border: Border.all(color: AppColors.surfaceContainerHigh),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WARNING: IMPORTING THIS ARCHIVE',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'WILL PERMANENTLY REPLACE ALL EXISTING LOCAL TELEMETRY.',
                      style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('SOURCE_ARCHIVE:', style: TextStyle(fontSize: 9, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w900)),
                        const SizedBox(width: 8),
                        Text(fileName.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'PROCEED WITH DATA_OVERRIDE?',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurfaceVariant,
                        side: const BorderSide(color: AppColors.surfaceContainerHigh),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('ABORT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(sheetContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('CONFIRM_OVERRIDE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
            ],
          ),
        );
      },
    );
  }
}