import 'package:uuid/uuid.dart';
import '../../domain/entities/event_entity.dart';
import '../data_sources/database_helper.dart';

class EventModel extends EventEntity {
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventModel({
    required super.id,
    required super.name,
    required super.date,
    required super.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromEntity(EventEntity entity) {
    final uuid = const Uuid().v4();
    return EventModel(
      id: entity.id.isEmpty ? uuid : entity.id,
      name: entity.name,
      date: entity.date,
      status: entity.status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as String,
      name: map['name'] as String,
      date: DatabaseHelper.stringToDateTime(map['date'] as String),
      status: EventStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => EventStatus.open,
      ),
      createdAt: DatabaseHelper.stringToDateTime(map['created_at'] as String),
      updatedAt: DatabaseHelper.stringToDateTime(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': DatabaseHelper.dateTimeToString(date),
      'status': status.name,
      'created_at': DatabaseHelper.dateTimeToString(createdAt),
      'updated_at': DatabaseHelper.dateTimeToString(updatedAt),
    };
  }

  @override
  EventModel copyWith({
    String? id,
    String? name,
    DateTime? date,
    EventStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [...super.props, createdAt, updatedAt];
}
