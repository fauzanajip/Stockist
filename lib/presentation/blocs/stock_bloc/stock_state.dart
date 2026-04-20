import 'package:equatable/equatable.dart';
import '../../../domain/entities/stock_mutation_entity.dart';

class StockState extends Equatable {
  final int totalGiven;
  final int totalReturn;
  final List<StockMutationEntity> mutations;

  const StockState({
    this.totalGiven = 0,
    this.totalReturn = 0,
    this.mutations = const [],
  });

  StockState copyWith({
    int? totalGiven,
    int? totalReturn,
    List<StockMutationEntity>? mutations,
  }) {
    return StockState(
      totalGiven: totalGiven ?? this.totalGiven,
      totalReturn: totalReturn ?? this.totalReturn,
      mutations: mutations ?? this.mutations,
    );
  }

  @override
  List<Object?> get props => [totalGiven, totalReturn, mutations];
}
