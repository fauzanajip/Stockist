import 'package:uuid/uuid.dart';
import '../../domain/entities/event_spg_entity.dart';
import '../data_sources/database_helper.dart';

class EventSpgModel extends EventSpgEntity {
  final DateTime createdAt;

  const EventSpgModel({
    required super.id,
    required super.eventId,
    required super.spgId,
    super.spbId,
    required this.createdAt,
  });

  factory EventSpgModel.fromEntity(EventSpgEntity entity) {
    final uuid = const Uuid().v4();
    return EventSpgModel(
      id: entity.id.isEmpty ? uuid : entity.id,
      eventId: entity.eventId,
      spgId: entity.spgId,
      spbId: entity.spbId,
      createdAt: DateTime.now(),
    );
  }

  factory EventSpgModel.fromMap(Map<String, dynamic> map) {
    return EventSpgModel(
      id: map['id'] as String,
      eventId: map['event_id'] as String,
      spgId: map['spg_id'] as String,
      spbId: map['spb_id'] as String?,
      createdAt: DatabaseHelper.stringToDateTime(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'spg_id': spgId,
      'spb_id': spbId,
      'created_at': DatabaseHelper.dateTimeToString(createdAt),
    };
  }

  @override
  EventSpgModel copyWith({
    String? id,
    String? eventId,
    String? spgId,
    String? spbId,
    DateTime? createdAt,
  }) {
    return EventSpgModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      spgId: spgId ?? this.spgId,
      spbId: spbId ?? this.spbId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [...super.props, createdAt];
}
