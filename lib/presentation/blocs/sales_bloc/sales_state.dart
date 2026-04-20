import 'package:equatable/equatable.dart';
import '../../domain/entities/sales_entity.dart';

class SalesState extends Equatable {
  final Map<String, int> salesByProduct;

  const SalesState({
    this.salesByProduct = const {},
  });

  SalesState copyWith({
    Map<String, int>? salesByProduct,
  }) {
    return SalesState(
      salesByProduct: salesByProduct ?? this.salesByProduct,
    );
  }

  @override
  List<Object?> get props => [salesByProduct];
}
