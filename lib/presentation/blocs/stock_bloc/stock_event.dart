import 'package:equatable/equatable.dart';
import '../../../domain/entities/stock_mutation_entity.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object?> get props => [];
}

class CreateInitialDistribution extends StockEvent {
  final String eventId;
  final String spgId;
  final String productId;
  final int qty;

  const CreateInitialDistribution({
    required this.eventId,
    required this.spgId,
    required this.productId,
    required this.qty,
  });

  @override
  List<Object?> get props => [eventId, spgId, productId, qty];
}

class CreateTopup extends StockEvent {
  final String eventId;
  final String spgId;
  final String productId;
  final int qty;
  final String? note;

  const CreateTopup({
    required this.eventId,
    required this.spgId,
    required this.productId,
    required this.qty,
    this.note,
  });

  @override
  List<Object?> get props => [eventId, spgId, productId, qty, note];
}

class CreateReturn extends StockEvent {
  final String eventId;
  final String spgId;
  final String productId;
  final int qty;
  final String? note;

  const CreateReturn({
    required this.eventId,
    required this.spgId,
    required this.productId,
    required this.qty,
    this.note,
  });

  @override
  List<Object?> get props => [eventId, spgId, productId, qty, note];
}

class LoadStockByEventSpg extends StockEvent {
  final String eventId;
  final String spgId;

  const LoadStockByEventSpg({
    required this.eventId,
    required this.spgId,
  });

  @override
  List<Object?> get props => [eventId, spgId];
}
