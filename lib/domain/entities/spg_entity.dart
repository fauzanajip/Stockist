import 'package:equatable/equatable.dart';

class SpgEntity extends Equatable {
  final String id;
  final String name;
  final DateTime? deletedAt;

  const SpgEntity({required this.id, required this.name, this.deletedAt});

  bool get isDeleted => deletedAt != null;

  SpgEntity copyWith({String? id, String? name, DateTime? deletedAt}) {
    return SpgEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, deletedAt];
}
