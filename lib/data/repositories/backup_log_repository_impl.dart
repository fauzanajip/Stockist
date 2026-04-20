import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../data_sources/database_helper.dart';
import '../models/backup_log_model.dart';
import '../../domain/entities/backup_log_entity.dart';
import '../../domain/repositories/backup_log_repository.dart';
import '../../../core/error/exceptions.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;

class BackupLogRepositoryImpl implements BackupLogRepository {
  final DatabaseHelper dbHelper;

  BackupLogRepositoryImpl({required this.dbHelper});

  @override
  Future<List<BackupLogEntity>> getByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'backup_logs',
        where: 'event_id = ?',
        whereArgs: [eventId],
        orderBy: 'timestamp DESC',
      );
      return maps.map((map) => BackupLogModel.fromMap(map)).toList();
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal mengambil data backup logs: $e');
    }
  }

  @override
  Future<BackupLogEntity> create(BackupLogEntity backupLog) async {
    try {
      final db = await dbHelper.database;
      final model = BackupLogModel(
        id: backupLog.id.isEmpty ? const Uuid().v4() : backupLog.id,
        eventId: backupLog.eventId,
        fileName: backupLog.fileName,
        timestamp: backupLog.timestamp,
        status: backupLog.status,
        createdAt: DateTime.now(),
      );
      await db.insert('backup_logs', model.toMap());
      return model;
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal membuat backup log: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'backup_logs',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException(message: 'Gagal hapus backup log: $e');
    }
  }
}
