import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/spb_usecases.dart' as spb_usecase;
import 'spb_event.dart';
import 'spb_state.dart';

class SpbBloc extends Bloc<SpbEvent, SpbState> {
  final spb_usecase.GetAllSpbs getAllSpbs;
  final spb_usecase.CreateSpb createSpb;
  final spb_usecase.UpdateSpb updateSpb;
  final spb_usecase.DeleteSpb deleteSpb;

  SpbBloc({
    required this.getAllSpbs,
    required this.createSpb,
    required this.updateSpb,
    required this.deleteSpb,
  }) : super(SpbInitial()) {
    on<LoadAllSpbs>(_onLoadAllSpbs);
    on<CreateSpbEvent>(_onCreateSpb);
    on<UpdateSpbEvent>(_onUpdateSpb);
    on<DeleteSpbEvent>(_onDeleteSpb);
  }

  Future<void> _onLoadAllSpbs(LoadAllSpbs event, Emitter<SpbState> emit) async {
    try {
      emit(SpbLoading());
      final spbs = await getAllSpbs();
      emit(SpbsLoaded(spbs: spbs));
    } catch (e) {
      emit(SpbError(message: e.toString()));
    }
  }

  Future<void> _onCreateSpb(
    CreateSpbEvent event,
    Emitter<SpbState> emit,
  ) async {
    try {
      final newSpb = await createSpb(event.name);
      emit(SpbCreated(spb: newSpb));
    } catch (e) {
      emit(SpbError(message: e.toString()));
    }
  }

  Future<void> _onUpdateSpb(
    UpdateSpbEvent event,
    Emitter<SpbState> emit,
  ) async {
    try {
      emit(SpbLoading());
      final updatedSpb = await updateSpb(event.spb);
      emit(SpbUpdated(spb: updatedSpb));
      add(LoadAllSpbs());
    } catch (e) {
      emit(SpbError(message: e.toString()));
    }
  }

  Future<void> _onDeleteSpb(
    DeleteSpbEvent event,
    Emitter<SpbState> emit,
  ) async {
    try {
      await deleteSpb(event.spbId);
      emit(SpbDeleted());
    } catch (e) {
      emit(SpbError(message: e.toString()));
    }
  }
}
