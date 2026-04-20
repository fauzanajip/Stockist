import 'package:equatable/equatable.dart';

class CashEvent extends Equatable {
  const CashEvent();

  @override
  List<Object?> get props => [];
}

class UpdateCashRecord extends CashEvent {
  final String eventId;
  final String spgId;
  final double cashReceived;
  final double qrisReceived;
  final String? note;

  const UpdateCashRecord({
    required this.eventId,
    required this.spgId,
    required this.cashReceived,
    required this.qrisReceived,
    this.note,
  });

  @override
  List<Object?> get props => [eventId, spgId, cashReceived, qrisReceived, note];
}

class LoadCashRecord extends CashEvent {
  final String eventId;
  final String spgId;

  const LoadCashRecord({
    required this.eventId,
    required this.spgId,
  });

  @override
  List<Object?> get props => [eventId, spgId];
}
