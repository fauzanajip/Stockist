import 'package:equatable/equatable.dart';

class EventSpgEntity extends Equatable {
  final String id;
  final String eventId;
  final String spgId;
  final String? spbId;

  const EventSpgEntity({
    required this.id,
    required this.eventId,
    required this.spgId,
    this.spbId,
  });

  EventSpgEntity copyWith({
    String? id,
    String? eventId,
    String? spgId,
    String? spbId,
  }) {
    return EventSpgEntity(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      spgId: spgId ?? this.spgId,
      spbId: spbId ?? this.spbId,
    );
  }

  @override
  List<Object?> get props => [id, eventId, spgId, spbId];
}
