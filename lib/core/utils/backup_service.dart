import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'downloader/downloader.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../../data/data_sources/database_helper.dart';
import '../error/exceptions.dart';

/// Backup service for exporting/importing event data as JSON
class BackupService {
  BackupService._();

  /// Export all event data to JSON file and share via Android Share Sheet
  static Future<void> exportBackup() async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Export all tables
      final backupData = {
        'export_date': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
        'events': await db.query('events'),
        'products': await db.query('products'),
        'spgs': await db.query('spgs'),
        'spbs': await db.query('spbs'),
        'event_spgs': await db.query('event_spgs'),
        'event_products': await db.query('event_products'),
        'stock_mutations': await db.query('stock_mutations'),
        'sales': await db.query('sales'),
        'cash_records': await db.query('cash_records'),
        'spg_product_targets': await db.query('spg_product_targets'),
        'pending_topups': await db.query('pending_topups'),
        'backup_logs': await db.query('backup_logs'),
      };

      final jsonString = JsonEncoder.withIndent('  ').convert(backupData);
      final fileName = 'stockist_backup_${DateTime.now().millisecondsSinceEpoch}.json';

      if (kIsWeb) {
        final bytes = utf8.encode(jsonString);
        await downloadFile(bytes, fileName, mimeType: 'application/json');
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsString(jsonString);
        final xFile = XFile(filePath);
        await Share.shareXFiles([xFile], text: 'Backup Data Stockist App');
      }

      // Log backup
      await db.insert('backup_logs', {
        'id': const Uuid().v4(),
        'event_id': '', // Global backup
        'file_name': fileName,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'success',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal export backup: $e');
    }
  }

  /// Export backup for specific event only
  static Future<void> exportEventBackup(String eventId) async {
    try {
      final db = await DatabaseHelper.instance.database;

      final backupData = {
        'export_date': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
        'event_id': eventId,
        'events': await db.query(
          'events',
          where: 'id = ?',
          whereArgs: [eventId],
        ),
        'event_spgs': await db.query(
          'event_spgs',
          where: 'event_id = ?',
          whereArgs: [eventId],
        ),
        'event_products': await db.query(
          'event_products',
          where: 'event_id = ?',
          whereArgs: [eventId],
        ),
        'stock_mutations': await db.query(
          'stock_mutations',
          where: 'event_id = ?',
          whereArgs: [eventId],
        ),
        'sales': await db.query(
          'sales',
          where: 'event_id = ?',
          whereArgs: [eventId],
        ),
        'cash_records': await db.query(
          'cash_records',
          where: 'event_id = ?',
          whereArgs: [eventId],
        ),
        'spg_product_targets': await db.query(
          'spg_product_targets',
          where: 'event_id = ?',
          whereArgs: [eventId],
        ),
        'pending_topups': await db.query(
          'pending_topups',
          where: 'event_id = ?',
          whereArgs: [eventId],
        ),
      };

      final jsonString = JsonEncoder.withIndent('  ').convert(backupData);
      final fileName = 'stockist_event_$eventId.json';

      if (kIsWeb) {
        final bytes = utf8.encode(jsonString);
        await downloadFile(bytes, fileName, mimeType: 'application/json');
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsString(jsonString);
        final xFile = XFile(filePath);
        await Share.shareXFiles([xFile], text: 'Backup Data Event Stockist');
      }

      await db.insert('backup_logs', {
        'id': const Uuid().v4(),
        'event_id': eventId,
        'file_name': fileName,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'success',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal export backup event: $e');
    }
  }

  /// Import backup from JSON file
  static Future<void> importBackup(PlatformFile file) async {
    try {
      String jsonString;
      if (kIsWeb) {
        jsonString = utf8.decode(file.bytes!);
      } else {
        jsonString = await File(file.path!).readAsString();
      }
      
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      final db = await DatabaseHelper.instance.database;
      final eventId = backupData['event_id'] as String?;
      final isGlobalBackup = eventId == null || eventId.isEmpty;

      await db.transaction((txn) async {
        // === GLOBAL BACKUP: Replace all master data ===
        if (isGlobalBackup) {
          // Products - delete all, then insert
          if (backupData['products'] != null) {
            await txn.delete('products');
            final products = List<Map<String, dynamic>>.from(backupData['products']);
            for (final product in products) {
              await txn.insert('products', product);
            }
          }

          // SPGs - delete all, then insert
          if (backupData['spgs'] != null) {
            await txn.delete('spgs');
            final spgs = List<Map<String, dynamic>>.from(backupData['spgs']);
            for (final spg in spgs) {
              await txn.insert('spgs', spg);
            }
          }

          // SPBs - delete all, then insert
          if (backupData['spbs'] != null) {
            await txn.delete('spbs');
            final spbs = List<Map<String, dynamic>>.from(backupData['spbs']);
            for (final spb in spbs) {
              await txn.insert('spbs', spb);
            }
          }

          // Events - delete all, then insert
          if (backupData['events'] != null) {
            await txn.delete('events');
            final events = List<Map<String, dynamic>>.from(backupData['events']);
            for (final event in events) {
              await txn.insert('events', event);
            }
          }

          // Event SPGs - delete all, then insert
          if (backupData['event_spgs'] != null) {
            await txn.delete('event_spgs');
            final eventSpgs = List<Map<String, dynamic>>.from(backupData['event_spgs']);
            for (final es in eventSpgs) {
              await txn.insert('event_spgs', es);
            }
          }

          // Event Products - delete all, then insert
          if (backupData['event_products'] != null) {
            await txn.delete('event_products');
            final eventProducts = List<Map<String, dynamic>>.from(backupData['event_products']);
            for (final ep in eventProducts) {
              await txn.insert('event_products', ep);
            }
          }

          // Stock Mutations - delete all, then insert
          if (backupData['stock_mutations'] != null) {
            await txn.delete('stock_mutations');
            final mutations = List<Map<String, dynamic>>.from(backupData['stock_mutations']);
            for (final m in mutations) {
              await txn.insert('stock_mutations', m);
            }
          }

          // Sales - delete all, then insert
          if (backupData['sales'] != null) {
            await txn.delete('sales');
            final sales = List<Map<String, dynamic>>.from(backupData['sales']);
            for (final s in sales) {
              await txn.insert('sales', s);
            }
          }

          // Cash Records - delete all, then insert
          if (backupData['cash_records'] != null) {
            await txn.delete('cash_records');
            final cashRecords = List<Map<String, dynamic>>.from(backupData['cash_records']);
            for (final c in cashRecords) {
              await txn.insert('cash_records', c);
            }
          }

          // SPG Product Targets - delete all, then insert
          if (backupData['spg_product_targets'] != null) {
            await txn.delete('spg_product_targets');
            final targets = List<Map<String, dynamic>>.from(backupData['spg_product_targets']);
            for (final t in targets) {
              await txn.insert('spg_product_targets', t);
            }
          }

          // Pending Topups - delete all, then insert
          if (backupData['pending_topups'] != null) {
            await txn.delete('pending_topups');
            final pendingTopups = List<Map<String, dynamic>>.from(backupData['pending_topups']);
            for (final pt in pendingTopups) {
              await txn.insert('pending_topups', pt);
            }
          }
        } else {
          // === EVENT-SPECIFIC BACKUP: Replace only event data ===

          // Event - delete existing, then insert
          if (backupData['events'] != null) {
            await txn.delete('events', where: 'id = ?', whereArgs: [eventId]);
            final events = List<Map<String, dynamic>>.from(backupData['events']);
            for (final event in events) {
              await txn.insert('events', event);
            }
          }

          // Event SPGs - delete existing for this event, then insert
          if (backupData['event_spgs'] != null) {
            await txn.delete('event_spgs', where: 'event_id = ?', whereArgs: [eventId]);
            final eventSpgs = List<Map<String, dynamic>>.from(backupData['event_spgs']);
            for (final es in eventSpgs) {
              await txn.insert('event_spgs', es);
            }
          }

          // Event Products - delete existing for this event, then insert
          if (backupData['event_products'] != null) {
            await txn.delete('event_products', where: 'event_id = ?', whereArgs: [eventId]);
            final eventProducts = List<Map<String, dynamic>>.from(backupData['event_products']);
            for (final ep in eventProducts) {
              await txn.insert('event_products', ep);
            }
          }

          // Stock Mutations - delete existing for this event, then insert
          if (backupData['stock_mutations'] != null) {
            await txn.delete('stock_mutations', where: 'event_id = ?', whereArgs: [eventId]);
            final mutations = List<Map<String, dynamic>>.from(backupData['stock_mutations']);
            for (final m in mutations) {
              await txn.insert('stock_mutations', m);
            }
          }

          // Sales - delete existing for this event, then insert
          if (backupData['sales'] != null) {
            await txn.delete('sales', where: 'event_id = ?', whereArgs: [eventId]);
            final sales = List<Map<String, dynamic>>.from(backupData['sales']);
            for (final s in sales) {
              await txn.insert('sales', s);
            }
          }

          // Cash Records - delete existing for this event, then insert
          if (backupData['cash_records'] != null) {
            await txn.delete('cash_records', where: 'event_id = ?', whereArgs: [eventId]);
            final cashRecords = List<Map<String, dynamic>>.from(backupData['cash_records']);
            for (final c in cashRecords) {
              await txn.insert('cash_records', c);
            }
          }

          // SPG Product Targets - delete existing for this event, then insert
          if (backupData['spg_product_targets'] != null) {
            await txn.delete('spg_product_targets', where: 'event_id = ?', whereArgs: [eventId]);
            final targets = List<Map<String, dynamic>>.from(backupData['spg_product_targets']);
            for (final t in targets) {
              await txn.insert('spg_product_targets', t);
            }
          }

          // Pending Topups - delete existing for this event, then insert
          if (backupData['pending_topups'] != null) {
            await txn.delete('pending_topups', where: 'event_id = ?', whereArgs: [eventId]);
            final pendingTopups = List<Map<String, dynamic>>.from(backupData['pending_topups']);
            for (final pt in pendingTopups) {
              await txn.insert('pending_topups', pt);
            }
          }
        }
      });

      await db.insert('backup_logs', {
        'id': const Uuid().v4(),
        'event_id': eventId ?? '',
        'file_name': file.name,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'success',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal import backup: $e');
    }
  }

  /// Check if backup reminder is needed (every 4 hours)
  static Future<bool> shouldShowBackupReminder() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT MAX(timestamp) as last_backup FROM backup_logs',
    );

    if (result.isEmpty || result.first['last_backup'] == null) {
      return true; // No backup yet
    }

    final lastBackup = DateTime.parse(result.first['last_backup'] as String);
    final hoursSinceBackup = DateTime.now().difference(lastBackup).inHours;

    return hoursSinceBackup >= 4;
  }
}
