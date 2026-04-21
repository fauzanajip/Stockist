import 'package:equatable/equatable.dart';
import '../../../domain/entities/cash_record_entity.dart';

class CashState extends Equatable {
  final double cashReceived;
  final double qrisReceived;
  final double actualCash;
  final List<CashRecordEntity> allCash;
  final bool isLoading;
  final String? errorMessage;

  const CashState({
    this.cashReceived = 0,
    this.qrisReceived = 0,
    this.actualCash = 0,
    this.allCash = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CashState copyWith({
    double? cashReceived,
    double? qrisReceived,
    double? actualCash,
    List<CashRecordEntity>? allCash,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CashState(
      cashReceived: cashReceived ?? this.cashReceived,
      qrisReceived: qrisReceived ?? this.qrisReceived,
      actualCash: actualCash ?? this.actualCash,
      allCash: allCash ?? this.allCash,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    cashReceived,
    qrisReceived,
    actualCash,
    allCash,
    isLoading,
    errorMessage,
  ];
}
