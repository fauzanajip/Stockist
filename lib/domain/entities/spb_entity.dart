import 'package:equatable/equatable.dart';

class SpbEntity extends Equatable {
  final String id;
  final String name;

  const SpbEntity({
    required this.id,
    required this.name,
  });

  SpbEntity copyWith({
    String? id,
    String? name,
  }) {
    return SpbEntity(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [id, name];
}
