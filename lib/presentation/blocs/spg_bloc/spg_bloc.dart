import 'package:flutter_bloc/flutter_bloc.dart';
import 'spg_event.dart';
import 'spg_state.dart';

class SpgBloc extends Bloc<SpgEvent, SpgState> {
  SpgBloc() : super(SpgInitial()) {
    on<LoadAllSpqs>(_onLoadAllSpqs);
    on<LoadActiveSpqs>(_onLoadActiveSpqs);
  }

  Future<void> _onLoadAllSpqs(
    LoadAllSpqs event,
    Emitter<SpgState> emit,
  ) async {
    emit(SpgLoading());
    // TODO: Implement with repository
  }

  Future<void> _onLoadActiveSpqs(
    LoadActiveSpqs event,
    Emitter<SpgState> emit,
  ) async {
    emit(SpgLoading());
    // TODO: Implement with repository
  }
}
