import 'package:equatable/equatable.dart';
import '../../../domain/entities/pending_topup_entity.dart';

class PendingTopupState extends Equatable {
  final bool isLoading;
  final List<PendingTopupEntity> pendingTopups;
  final PendingTopupEntity? selectedTopup;
  final String? errorMessage;

  const PendingTopupState({
    this.isLoading = false,
    this.pendingTopups = const [],
    this.selectedTopup,
    this.errorMessage,
  });

  PendingTopupState copyWith({
    bool? isLoading,
    List<PendingTopupEntity>? pendingTopups,
    PendingTopupEntity? selectedTopup,
    String? errorMessage,
  }) {
    return PendingTopupState(
      isLoading: isLoading ?? this.isLoading,
      pendingTopups: pendingTopups ?? this.pendingTopups,
      selectedTopup: selectedTopup ?? this.selectedTopup,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, pendingTopups, selectedTopup, errorMessage];
}