import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../data_sources/database_helper.dart';
import '../models/backup_log_model.dart';
import '../../domain/entities/backup_log_entity.dart';
import '../../domain/repositories/backup_log_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class BackupLogRepositoryImpl implements BackupLogRepository {
  final DatabaseHelper dbHelper;

  BackupLogRepositoryImpl({required this.dbHelper});

  @override
  Future<Either<Failure, List<BackupLogEntity>>> getByEvent(String eventId) async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'backup_logs',
        where: 'event_id = ?',
        whereArgs: [eventId],
        orderBy: 'timestamp DESC',
      );
      return Right(maps.map((map) => BackupLogModel.fromMap(map)).toList());
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal mengambil data backup logs'));
    }
  }

  @override
  Future<Either<Failure, BackupLogEntity>> create(BackupLogEntity backupLog) async {
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
      return Right(model);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal membuat backup log'));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      final db = await dbHelper.database;
      await db.delete(
        'backup_logs',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Right(null);
    } catch (e) {
      return const Left(DatabaseFailure(message: 'Gagal hapus backup log'));
    }
  }
}
