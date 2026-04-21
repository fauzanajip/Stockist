import 'package:uuid/uuid.dart';
import '../../domain/entities/spg_entity.dart';
import '../data_sources/database_helper.dart';

class SpgModel extends SpgEntity {
  final DateTime createdAt;
  final DateTime updatedAt;

  const SpgModel({
    required super.id,
    required super.name,
    super.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SpgModel.fromEntity(SpgEntity entity) {
    final uuid = const Uuid().v4();
    return SpgModel(
      id: entity.id.isEmpty ? uuid : entity.id,
      name: entity.name,
      deletedAt: entity.deletedAt,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory SpgModel.fromMap(Map<String, dynamic> map) {
    return SpgModel(
      id: map['id'] as String,
      name: map['name'] as String,
      deletedAt: map['deleted_at'] != null 
          ? DatabaseHelper.stringToDateTime(map['deleted_at'] as String) 
          : null,
      createdAt: DatabaseHelper.stringToDateTime(map['created_at'] as String),
      updatedAt: DatabaseHelper.stringToDateTime(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'deleted_at': deletedAt != null ? DatabaseHelper.dateTimeToString(deletedAt!) : null,
      'created_at': DatabaseHelper.dateTimeToString(createdAt),
      'updated_at': DatabaseHelper.dateTimeToString(updatedAt),
    };
  }

  @override
  SpgModel copyWith({
    String? id,
    String? name,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SpgModel(
      id: id ?? this.id,
      name: name ?? this.name,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [...super.props, createdAt, updatedAt];
}
