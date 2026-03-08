import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/bang_gia_entity.dart';
import '../../../domain/usecases/them_bang_gia.dart';
import '../../../domain/usecases/watch_bang_gia_list.dart';
import '../../../domain/usecases/update_bang_gia_cho_phong_list.dart';
import '../../../domain/usecases/xoa_bang_gia.dart';
import '../../../domain/usecases/update_bang_gia.dart';
import 'bang_gia_event.dart';
import 'bang_gia_state.dart';

class BangGiaBloc extends Bloc<BangGiaEvent, BangGiaState> {
  final WatchBangGiaListUseCase _watchBangGiaListUseCase;
  final ThemBangGiaUseCase _themBangGiaUseCase;
  final UpdateBangGiaChoPhongListUseCase _updateBangGiaChoPhongListUseCase;
  final XoaBangGiaUseCase _xoaBangGiaUseCase;
  final UpdateBangGiaUseCase _updateBangGiaUseCase;

  BangGiaBloc({
    required WatchBangGiaListUseCase watchBangGiaListUseCase,
    required ThemBangGiaUseCase themBangGiaUseCase,
    required UpdateBangGiaChoPhongListUseCase updateBangGiaChoPhongListUseCase,
    required XoaBangGiaUseCase xoaBangGiaUseCase,
    required UpdateBangGiaUseCase updateBangGiaUseCase,
  })  : _watchBangGiaListUseCase = watchBangGiaListUseCase,
        _themBangGiaUseCase = themBangGiaUseCase,
        _updateBangGiaChoPhongListUseCase = updateBangGiaChoPhongListUseCase,
        _xoaBangGiaUseCase = xoaBangGiaUseCase,
        _updateBangGiaUseCase = updateBangGiaUseCase,
        super(BangGiaInitial()) {
    on<BangGiaStarted>(_onStarted);
    on<ThemBangGiaRequested>(_onThemBangGiaRequested);
    on<XoaBangGiaRequested>(_onXoaBangGiaRequested);
    on<UpdateBangGiaRequested>(_onUpdateBangGiaRequested);
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

  Future<void> _onXoaBangGiaRequested(
    XoaBangGiaRequested event,
    Emitter<BangGiaState> emit,
  ) async {
    // Không emit Loading để tránh bị trắng màn hình chính (do buildWhen)
    // Nhưng có thể dùng ScaffoldMessenger để báo đang xóa nếu cần
    try {
      await _xoaBangGiaUseCase(event.bangGiaId, event.chuNhaId);
      // Danh sách sẽ tự cập nhật nhờ stream trong _onStarted
    } catch (e) {
      emit(BangGiaError(e.toString()));
    }
  }

  Future<void> _onUpdateBangGiaRequested(
    UpdateBangGiaRequested event,
    Emitter<BangGiaState> emit,
  ) async {
    emit(ThemBangGiaLoading());
    try {
      await _updateBangGiaUseCase(event.bangGia);
      emit(ThemBangGiaSuccess());
    } catch (e) {
      emit(ThemBangGiaFailure(e.toString()));
    }
  }
}
