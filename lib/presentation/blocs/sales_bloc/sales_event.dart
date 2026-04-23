import 'package:equatable/equatable.dart';

class SalesEvent extends Equatable {
  const SalesEvent();

  @override
  List<Object?> get props => [];
}

class UpdateSales extends SalesEvent {
  final String eventId;
  final String spgId;
  final String productId;
  final int qtySold;

  const UpdateSales({
    required this.eventId,
    required this.spgId,
    required this.productId,
    required this.qtySold,
  });

  @override
  List<Object?> get props => [eventId, spgId, productId, qtySold];
}

class LoadSales extends SalesEvent {
  final String eventId;
  final String spgId;

  const LoadSales({required this.eventId, required this.spgId});

  @override
  List<Object?> get props => [eventId, spgId];
}

class LoadAllSalesByEvent extends SalesEvent {
  final String eventId;

  const LoadAllSalesByEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}
