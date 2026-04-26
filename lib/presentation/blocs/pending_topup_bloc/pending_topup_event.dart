import 'package:equatable/equatable.dart';
import '../../../domain/entities/pending_topup_entity.dart';

abstract class PendingTopupEvent extends Equatable {
  const PendingTopupEvent();

  @override
  List<Object?> get props => [];
}

class LoadPendingTopupsEvent extends PendingTopupEvent {
  final String eventId;
  final String? spbId;

  const LoadPendingTopupsEvent({required this.eventId, this.spbId});

  @override
  List<Object?> get props => [eventId, spbId];
}

class AddPendingTopupEvent extends PendingTopupEvent {
  final String eventId;
  final String? spbId;
  final String spgId;
  final String productId;
  final int qty;

  const AddPendingTopupEvent({
    required this.eventId,
    this.spbId,
    required this.spgId,
    required this.productId,
    required this.qty,
  });

  @override
  List<Object?> get props => [eventId, spbId, spgId, productId, qty];
}

class TogglePendingTopupCheckEvent extends PendingTopupEvent {
  final String id;
  final bool isChecked;

  const TogglePendingTopupCheckEvent({required this.id, required this.isChecked});

  @override
  List<Object?> get props => [id, isChecked];
}

class UpdatePendingTopupEvent extends PendingTopupEvent {
  final String id;
  final String? spbId;
  final String spgId;
  final String productId;
  final int qty;

  const UpdatePendingTopupEvent({
    required this.id,
    this.spbId,
    required this.spgId,
    required this.productId,
    required this.qty,
  });

  @override
  List<Object?> get props => [id, spbId, spgId, productId, qty];
}

class DeletePendingTopupEvent extends PendingTopupEvent {
  final String id;

  const DeletePendingTopupEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class SelectPendingTopupEvent extends PendingTopupEvent {
  final PendingTopupEntity? topup;

  const SelectPendingTopupEvent({this.topup});

  @override
  List<Object?> get props => [topup];
}

class ClearSelectionEvent extends PendingTopupEvent {
  const ClearSelectionEvent();
}