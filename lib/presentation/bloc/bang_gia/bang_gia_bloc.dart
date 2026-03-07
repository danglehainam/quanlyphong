import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/bang_gia_entity.dart';
import '../../../domain/usecases/them_bang_gia.dart';
import '../../../domain/usecases/watch_bang_gia_list.dart';
import 'bang_gia_event.dart';
import 'bang_gia_state.dart';

class BangGiaBloc extends Bloc<BangGiaEvent, BangGiaState> {
  final WatchBangGiaListUseCase _watchBangGiaListUseCase;
  final ThemBangGiaUseCase _themBangGiaUseCase;

  BangGiaBloc({
    required WatchBangGiaListUseCase watchBangGiaListUseCase,
    required ThemBangGiaUseCase themBangGiaUseCase,
  })  : _watchBangGiaListUseCase = watchBangGiaListUseCase,
        _themBangGiaUseCase = themBangGiaUseCase,
        super(BangGiaInitial()) {
    on<BangGiaStarted>(_onStarted);
    on<ThemBangGiaRequested>(_onThemBangGiaRequested);
  }

  Future<void> _onStarted(
    BangGiaStarted event,
    Emitter<BangGiaState> emit,
  ) async {
    emit(BangGiaLoading());
    
    await emit.forEach<List<BangGiaEntity>>(
      _watchBangGiaListUseCase(event.chuNhaId),
      onData: (items) => BangGiaLoaded(items),
      onError: (error, stackTrace) => BangGiaError(error.toString()),
    );
  }

  Future<void> _onThemBangGiaRequested(
    ThemBangGiaRequested event,
    Emitter<BangGiaState> emit,
  ) async {
    emit(ThemBangGiaLoading());
    try {
      await _themBangGiaUseCase(event.bangGia);
      emit(ThemBangGiaSuccess());
    } catch (e) {
      emit(ThemBangGiaFailure(e.toString()));
    }
  }
}
