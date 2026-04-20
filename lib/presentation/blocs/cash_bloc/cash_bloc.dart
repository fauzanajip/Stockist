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
  }

  Future<void> _onLoadCashRecord(
    LoadCashRecord event,
    Emitter<CashState> emit,
  ) async {
    final result = await getCashRecordByEventSpg(event.eventId, event.spgId);
    
    result.fold(
      (failure) => {},
      (cashRecord) {
        if (cashRecord != null) {
          emit(CashState(
            cashReceived: cashRecord.cashReceived,
            qrisReceived: cashRecord.qrisReceived,
            actualCash: cashRecord.actualCash,
          ));
        }
      },
    );
  }
}
