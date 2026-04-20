import '../../domain/entities/backup_log_entity.dart';
import '../data_sources/database_helper.dart';

class BackupLogModel extends BackupLogEntity {
  final DateTime createdAt;

  const BackupLogModel({
    required super.id,
    required super.eventId,
    required super.fileName,
    required super.timestamp,
    required super.status,
    required this.createdAt,
  });

  factory BackupLogModel.fromEntity(BackupLogEntity entity) {
    return BackupLogModel(
      id: entity.id,
      eventId: entity.eventId,
      fileName: entity.fileName,
      timestamp: entity.timestamp,
      status: entity.status,
      createdAt: DateTime.now(),
    );
  }

  factory BackupLogModel.fromMap(Map<String, dynamic> map) {
    return BackupLogModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      fileName: map['file_name'] as String,
      timestamp: DatabaseHelper.stringToDateTime(map['timestamp'] as String),
      status: BackupStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BackupStatus.failed,
      ),
      createdAt: DatabaseHelper.stringToDateTime(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'file_name': fileName,
      'timestamp': DatabaseHelper.dateTimeToString(timestamp),
      'status': status.name,
      'created_at': DatabaseHelper.dateTimeToString(createdAt),
    };
  }

  BackupLogModel copyWith({
    String? id,
    String? eventId,
    String? fileName,
    DateTime? timestamp,
    BackupStatus? status,
    DateTime? createdAt,
  }) {
    return BackupLogModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      fileName: fileName ?? this.fileName,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [...super.props, createdAt];
}
