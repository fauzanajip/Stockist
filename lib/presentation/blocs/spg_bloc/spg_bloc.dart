import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/spg_usecases.dart' as usecase;
import 'spg_event.dart';
import 'spg_state.dart';

class SpgBloc extends Bloc<SpgEvent, SpgState> {
  final usecase.GetAllSpgs getAllSpgs;
  final usecase.GetActiveSpgs getActiveSpgs;
  final usecase.CreateSpg createSpg;
  final usecase.SoftDeleteSpg softDeleteSpg;

  SpgBloc({
    required this.getAllSpgs,
    required this.getActiveSpgs,
    required this.createSpg,
    required this.softDeleteSpg,
  }) : super(SpgInitial()) {
    on<LoadAllSpqs>(_onLoadAllSpqs);
    on<LoadActiveSpqs>(_onLoadActiveSpqs);
    on<CreateNewSpq>(_onCreateNewSpq);
    on<SoftDeleteSpqEvent>(_onSoftDeleteSpq);
  }

  Future<void> _onLoadAllSpqs(
    LoadAllSpqs event,
    Emitter<SpgState> emit,
  ) async {
    try {
      emit(SpgLoading());
      final spgs = await getAllSpgs();
      emit(SpqsLoaded(spqs: spgs));
    } catch (e) {
      emit(SpgError(message: e.toString()));
    }
  }

  Future<void> _onLoadActiveSpqs(
    LoadActiveSpqs event,
    Emitter<SpgState> emit,
  ) async {
    try {
      emit(SpgLoading());
      final spgs = await getActiveSpgs();
      emit(SpqsLoaded(spqs: spgs));
    } catch (e) {
      emit(SpgError(message: e.toString()));
    }
  }

  Future<void> _onCreateNewSpq(
    CreateNewSpq event,
    Emitter<SpgState> emit,
  ) async {
    try {
      emit(SpgLoading());
      await createSpg(event.name);
      emit(SpqCreated());
      add(LoadActiveSpqs());
    } catch (e) {
      emit(SpgError(message: e.toString()));
    }
  }

  Future<void> _onSoftDeleteSpq(
    SoftDeleteSpqEvent event,
    Emitter<SpgState> emit,
  ) async {
    try {
      emit(SpgLoading());
      await softDeleteSpg(event.id);
      emit(SpqDeleted());
      add(LoadActiveSpqs());
    } catch (e) {
      emit(SpgError(message: e.toString()));
    }
  }
}