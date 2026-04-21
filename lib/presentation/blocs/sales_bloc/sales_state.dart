import 'package:equatable/equatable.dart';
import '../../../domain/entities/sales_entity.dart';

class SalesState extends Equatable {
  final Map<String, int> salesByProduct;
  final List<SalesEntity> allSales;
  final bool isLoading;
  final String? errorMessage;

  const SalesState({
    this.salesByProduct = const {},
    this.allSales = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SalesState copyWith({
    Map<String, int>? salesByProduct,
    List<SalesEntity>? allSales,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SalesState(
      salesByProduct: salesByProduct ?? this.salesByProduct,
      allSales: allSales ?? this.allSales,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [salesByProduct, allSales, isLoading, errorMessage];
}

