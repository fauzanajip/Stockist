import '../entities/backup_log_entity.dart';

abstract class BackupLogRepository {
  Future<List<BackupLogEntity>> getByEvent(String eventId);
  Future<BackupLogEntity> create(BackupLogEntity backupLog);
  Future<void> delete(String id);
}
