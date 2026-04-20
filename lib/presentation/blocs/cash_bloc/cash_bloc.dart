import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/cash_record_usecases.dart';
import 'cash_bloc.dart';

class CashBloc extends Bloc<CashEvent, CashState> {
  final CreateOrUpdateCashRecord createOrUpdateCashRecord;
  final GetCashRecordByEventSpg getCashRecordByEventSpg;

  CashBloc({
    required this.createOrUpdateCashRecord,
    required this.getCashRecordByEventSpg,
  }) : super(const CashState()) {
    on<UpdateCashRecord>(_onUpdateCashRecord);
    on<LoadCashRecord>(_onLoadCashRecord);
  }

  Future<void> _onUpdateCashRecord(
    UpdateCashRecord event,
    Emitter<CashState> emit,
  ) async {
    try {
      await createOrUpdateCashRecord(
        CreateOrUpdateCashRecordParams(
          eventId: event.eventId,
          spgId: event.spgId,
          cashReceived: event.cashReceived,
          qrisReceived: event.qrisReceived,
          note: event.note,
        ),
      );
      add(LoadCashRecord(eventId: event.eventId, spgId: event.spgId));
    } catch (e) {
      // TODO: Emit error state
    }
  }

  Future<void> _onLoadCashRecord(
    LoadCashRecord event,
    Emitter<CashState> emit,
  ) async {
    try {
      final cashRecord = await getCashRecordByEventSpg(event.eventId, event.spgId);
      if (cashRecord != null) {
        emit(CashState(
          cashReceived: cashRecord.cashReceived,
          qrisReceived: cashRecord.qrisReceived,
          actualCash: cashRecord.actualCash,
        ));
      }
    } catch (e) {
      // TODO: Emit error state
    }
  }
}
