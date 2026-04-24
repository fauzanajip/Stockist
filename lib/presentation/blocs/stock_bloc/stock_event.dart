import 'package:equatable/equatable.dart';
import '../../../domain/repositories/stock_mutation_repository.dart';

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

class BulkCreateOrUpdateInitialDistributionEvent extends StockEvent {
  final List<BulkInitialParams> distributions;

  const BulkCreateOrUpdateInitialDistributionEvent({required this.distributions});

  @override
  List<Object?> get props => [distributions];
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

  const LoadStockByEventSpg({required this.eventId, required this.spgId});

  @override
  List<Object?> get props => [eventId, spgId];
}

class LoadStockByEvent extends StockEvent {
  final String eventId;

  const LoadStockByEvent({required this.eventId});

  @override
  List<Object?> get props => [eventId];
}

class CreateDistributorStock extends StockEvent {
  final String eventId;
  final String productId;
  final int qty;

  const CreateDistributorStock({
    required this.eventId,
    required this.productId,
    required this.qty,
  });

  @override
  List<Object?> get props => [eventId, productId, qty];
}

class UpdateStockMutation extends StockEvent {
  final String mutationId;
  final String eventId;
  final String spgId;
  final String productId;
  final int newQty;

  const UpdateStockMutation({
    required this.mutationId,
    required this.eventId,
    required this.spgId,
    required this.productId,
    required this.newQty,
  });

  @override
  List<Object?> get props => [mutationId, eventId, spgId, productId, newQty];
}

class DeleteStockMutation extends StockEvent {
  final String mutationId;
  final String eventId;
  final String spgId;

  const DeleteStockMutation({
    required this.mutationId,
    required this.eventId,
    required this.spgId,
  });

  @override
  List<Object?> get props => [mutationId, eventId, spgId];
}
