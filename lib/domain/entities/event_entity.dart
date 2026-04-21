import 'package:equatable/equatable.dart';

enum EventStatus { open, closed }

class EventEntity extends Equatable {
  final String id;
  final String name;
  final DateTime date;
  final EventStatus status;
  final bool isActive;

  const EventEntity({
    required this.id,
    required this.name,
    required this.date,
    required this.status,
    this.isActive = false,
  });

  EventEntity copyWith({
    String? id,
    String? name,
    DateTime? date,
    EventStatus? status,
    bool? isActive,
  }) {
    return EventEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, date, status, isActive];
}
