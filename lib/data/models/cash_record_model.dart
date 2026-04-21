import 'package:uuid/uuid.dart';
import '../../domain/entities/cash_record_entity.dart';
import '../data_sources/database_helper.dart';

class CashRecordModel extends CashRecordEntity {
  final DateTime createdAt;
  final DateTime updatedAt;

  const CashRecordModel({
    required super.id,
    required super.eventId,
    required super.spgId,
    required super.cashReceived,
    required super.qrisReceived,
    super.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CashRecordModel.fromEntity(CashRecordEntity entity) {
    final uuid = const Uuid().v4();
    return CashRecordModel(
      id: entity.id.isEmpty ? uuid : entity.id,
      eventId: entity.eventId,
      spgId: entity.spgId,
      cashReceived: entity.cashReceived,
      qrisReceived: entity.qrisReceived,
      note: entity.note,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory CashRecordModel.fromMap(Map<String, dynamic> map) {
    return CashRecordModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      spgId: map['spg_id'] as String,
      cashReceived: (map['cash_received'] as num).toDouble(),
      qrisReceived: (map['qris_received'] as num).toDouble(),
      note: map['note'] as String?,
      createdAt: DatabaseHelper.stringToDateTime(map['created_at'] as String),
      updatedAt: DatabaseHelper.stringToDateTime(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'spg_id': spgId,
      'cash_received': cashReceived,
      'qris_received': qrisReceived,
      'note': note,
      'created_at': DatabaseHelper.dateTimeToString(createdAt),
      'updated_at': DatabaseHelper.dateTimeToString(updatedAt),
    };
  }

  @override
  CashRecordModel copyWith({
    String? id,
    String? eventId,
    String? spgId,
    double? cashReceived,
    double? qrisReceived,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CashRecordModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      spgId: spgId ?? this.spgId,
      cashReceived: cashReceived ?? this.cashReceived,
      qrisReceived: qrisReceived ?? this.qrisReceived,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [...super.props, createdAt, updatedAt];
}
