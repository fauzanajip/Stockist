import 'package:equatable/equatable.dart';
import '../../../domain/entities/stock_mutation_entity.dart';

class StockState extends Equatable {
  final int totalGiven;
  final int totalReturn;
  final List<StockMutationEntity> mutations;
  final bool isLoading;
  final String? errorMessage;

  const StockState({
    this.totalGiven = 0,
    this.totalReturn = 0,
    this.mutations = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  StockState copyWith({
    int? totalGiven,
    int? totalReturn,
    List<StockMutationEntity>? mutations,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StockState(
      totalGiven: totalGiven ?? this.totalGiven,
      totalReturn: totalReturn ?? this.totalReturn,
      mutations: mutations ?? this.mutations,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    totalGiven,
    totalReturn,
    mutations,
    isLoading,
    errorMessage,
  ];
}
