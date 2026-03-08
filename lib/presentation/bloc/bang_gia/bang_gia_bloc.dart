import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/bang_gia_entity.dart';
import '../../../domain/usecases/them_bang_gia.dart';
import '../../../domain/usecases/watch_bang_gia_list.dart';
import '../../../domain/usecases/update_bang_gia_cho_phong_list.dart';
import 'bang_gia_event.dart';
import 'bang_gia_state.dart';

class BangGiaBloc extends Bloc<BangGiaEvent, BangGiaState> {
  final WatchBangGiaListUseCase _watchBangGiaListUseCase;
  final ThemBangGiaUseCase _themBangGiaUseCase;
  final UpdateBangGiaChoPhongListUseCase _updateBangGiaChoPhongListUseCase;

  BangGiaBloc({
    required WatchBangGiaListUseCase watchBangGiaListUseCase,
    required ThemBangGiaUseCase themBangGiaUseCase,
    required UpdateBangGiaChoPhongListUseCase updateBangGiaChoPhongListUseCase,
  })  : _watchBangGiaListUseCase = watchBangGiaListUseCase,
        _themBangGiaUseCase = themBangGiaUseCase,
        _updateBangGiaChoPhongListUseCase = updateBangGiaChoPhongListUseCase,
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
      final bangGiaId = await _themBangGiaUseCase(event.bangGia);
      
      // Nếu có phòng được chọn, áp dụng bảng giá cho chúng
      if (event.selectedPhongIds.isNotEmpty) {
        await _updateBangGiaChoPhongListUseCase(
          event.selectedPhongIds,
          bangGiaId,
        );
      }
      
      emit(ThemBangGiaSuccess());
    } catch (e) {
      emit(ThemBangGiaFailure(e.toString()));
    }
  }
}
