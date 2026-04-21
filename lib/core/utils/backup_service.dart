import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
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
        'backup_logs': await db.query('backup_logs'),
      };

      final jsonString = JsonEncoder.withIndent('  ').convert(backupData);
      
      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'stockist_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // Share via Android Share Sheet
      final xFile = XFile(filePath);
      await Share.shareXFiles(
        [xFile],
        text: 'Backup Data Stockist App',
      );

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
        'events': await db.query('events', where: 'id = ?', whereArgs: [eventId]),
        'event_spgs': await db.query('event_spgs', where: 'event_id = ?', whereArgs: [eventId]),
        'event_products': await db.query('event_products', where: 'event_id = ?', whereArgs: [eventId]),
        'stock_mutations': await db.query('stock_mutations', where: 'event_id = ?', whereArgs: [eventId]),
        'sales': await db.query('sales', where: 'event_id = ?', whereArgs: [eventId]),
        'cash_records': await db.query('cash_records', where: 'event_id = ?', whereArgs: [eventId]),
      };

      final jsonString = JsonEncoder.withIndent('  ').convert(backupData);
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'stockist_event_$eventId.json';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsString(jsonString);

      final xFile = XFile(filePath);
      await Share.shareXFiles(
        [xFile],
        text: 'Backup Data Event Stockist',
      );

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
  static Future<void> importBackup(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      final db = await DatabaseHelper.instance.database;
      
      await db.transaction((txn) async {
        // Import events
        if (backupData['events'] != null) {
          final events = List<Map<String, dynamic>>.from(backupData['events']);
          for (final event in events) {
            await txn.insert('events', event);
          }
        }

        // Import products (only if global backup)
        if (backupData['products'] != null) {
          final products = List<Map<String, dynamic>>.from(backupData['products']);
          for (final product in products) {
            await txn.insert('products', product);
          }
        }

        // Import SPGs (only if global backup)
        if (backupData['spgs'] != null) {
          final spgs = List<Map<String, dynamic>>.from(backupData['spgs']);
          for (final spg in spgs) {
            await txn.insert('spgs', spg);
          }
        }

        // Import other tables...
        // TODO: Implement for all tables
      });

      await db.insert('backup_logs', {
        'id': const Uuid().v4(),
        'event_id': backupData['event_id'] ?? '',
        'file_name': filePath.split('/').last,
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
