import 'package:equatable/equatable.dart';

class CashRecordEntity extends Equatable {
  final String id;
  final String eventId;
  final String spgId;
  final double cashReceived;
  final double qrisReceived;
  final String? note;

  const CashRecordEntity({
    required this.id,
    required this.eventId,
    required this.spgId,
    required this.cashReceived,
    required this.qrisReceived,
    this.note,
  });

  double get actualCash => cashReceived + qrisReceived;

  CashRecordEntity copyWith({
    String? id,
    String? eventId,
    String? spgId,
    double? cashReceived,
    double? qrisReceived,
    String? note,
  }) {
    return CashRecordEntity(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      spgId: spgId ?? this.spgId,
      cashReceived: cashReceived ?? this.cashReceived,
      qrisReceived: qrisReceived ?? this.qrisReceived,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [
    id,
    eventId,
    spgId,
    cashReceived,
    qrisReceived,
    note,
  ];
}
