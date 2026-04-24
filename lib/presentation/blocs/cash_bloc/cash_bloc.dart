import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/cash_record_usecases.dart';
import 'cash_event.dart';
import 'cash_state.dart';

class CashBloc extends Bloc<CashEvent, CashState> {
  final CreateOrUpdateCashRecord createOrUpdateCashRecord;
  final GetCashRecordByEventSpg getCashRecordByEventSpg;
  final GetCashRecordsByEvent getCashRecordsByEvent;

  CashBloc({
    required this.createOrUpdateCashRecord,
    required this.getCashRecordByEventSpg,
    required this.getCashRecordsByEvent,
  }) : super(const CashState()) {
    on<UpdateCashRecord>(_onUpdateCashRecord);
    on<LoadCashRecord>(_onLoadCashRecord);
    on<LoadAllCashByEvent>(_onLoadAllCashByEvent);
  }

  Future<void> _onUpdateCashRecord(
    UpdateCashRecord event,
    Emitter<CashState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      await createOrUpdateCashRecord(
        CreateOrUpdateCashRecordParams(
          eventId: event.eventId,
          spgId: event.spgId,
          cashReceived: event.cashReceived,
          qrisReceived: event.qrisReceived,
          note: event.note,
        ),
      );
      add(LoadAllCashByEvent(eventId: event.eventId));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadCashRecord(
    LoadCashRecord event,
    Emitter<CashState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final cashRecord = await getCashRecordByEventSpg(
        event.eventId,
        event.spgId,
      );
      if (cashRecord != null) {
        emit(
          state.copyWith(
            isLoading: false,
            hasRecord: true,
            cashReceived: cashRecord.cashReceived,
            qrisReceived: cashRecord.qrisReceived,
            actualCash: cashRecord.actualCash,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            hasRecord: false,
            cashReceived: 0,
            qrisReceived: 0,
            actualCash: 0,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadAllCashByEvent(
    LoadAllCashByEvent event,
    Emitter<CashState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final allCash = await getCashRecordsByEvent(event.eventId);
      emit(state.copyWith(isLoading: false, allCash: allCash));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
