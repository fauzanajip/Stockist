import 'package:equatable/equatable.dart';

enum BackupStatus { success, failed }

class BackupLogEntity extends Equatable {
  final String id;
  final String eventId;
  final String fileName;
  final DateTime timestamp;
  final BackupStatus status;

  const BackupLogEntity({
    required this.id,
    required this.eventId,
    required this.fileName,
    required this.timestamp,
    required this.status,
  });

  BackupLogEntity copyWith({
    String? id,
    String? eventId,
    String? fileName,
    DateTime? timestamp,
    BackupStatus? status,
  }) {
    return BackupLogEntity(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      fileName: fileName ?? this.fileName,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, eventId, fileName, timestamp, status];
}
