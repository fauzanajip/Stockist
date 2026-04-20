import '../../domain/entities/spb_entity.dart';
import '../data_sources/database_helper.dart';

class SpbModel extends SpbEntity {
  final DateTime createdAt;

  const SpbModel({
    required super.id,
    required super.name,
    required this.createdAt,
  });

  factory SpbModel.fromEntity(SpbEntity entity) {
    return SpbModel(
      id: entity.id,
      name: entity.name,
      createdAt: DateTime.now(),
    );
  }

  factory SpbModel.fromMap(Map<String, dynamic> map) {
    return SpbModel(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DatabaseHelper.stringToDateTime(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': DatabaseHelper.dateTimeToString(createdAt),
    };
  }

  SpbModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return SpbModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [...super.props, createdAt];
}
