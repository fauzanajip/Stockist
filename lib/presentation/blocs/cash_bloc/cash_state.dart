import 'package:equatable/equatable.dart';

class CashState extends Equatable {
  final double cashReceived;
  final double qrisReceived;
  final double actualCash;

  const CashState({
    this.cashReceived = 0,
    this.qrisReceived = 0,
    this.actualCash = 0,
  });

  CashState copyWith({
    double? cashReceived,
    double? qrisReceived,
    double? actualCash,
  }) {
    return CashState(
      cashReceived: cashReceived ?? this.cashReceived,
      qrisReceived: qrisReceived ?? this.qrisReceived,
      actualCash: actualCash ?? this.actualCash,
    );
  }

  @override
  List<Object?> get props => [cashReceived, qrisReceived, actualCash];
}
