import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'nguoi_thue_event.dart';
import 'nguoi_thue_state.dart';
import '../../../domain/usecases/watch_nguoi_thue_list.dart';
import '../../../domain/usecases/them_nguoi_thue.dart';
import '../../../domain/usecases/update_nguoi_thue.dart';
import '../../../domain/usecases/xoa_nguoi_thue.dart';
import '../../../domain/entities/nguoi_thue_entity.dart';

class NguoiThueBloc extends Bloc<NguoiThueEvent, NguoiThueState> {
  final WatchNguoiThueListUseCase _watchNguoiThueList;
  final ThemNguoiThueUseCase _themNguoiThue;
  final UpdateNguoiThueUseCase _updateNguoiThue;
  final XoaNguoiThueUseCase _xoaNguoiThue;

  StreamSubscription? _nguoiThueSub;
  List<NguoiThueEntity> _items = [];

  NguoiThueBloc({
    required WatchNguoiThueListUseCase watchNguoiThueList,
    required ThemNguoiThueUseCase themNguoiThue,
    required UpdateNguoiThueUseCase updateNguoiThue,
    required XoaNguoiThueUseCase xoaNguoiThue,
  })  : _watchNguoiThueList = watchNguoiThueList,
        _themNguoiThue = themNguoiThue,
        _updateNguoiThue = updateNguoiThue,
        _xoaNguoiThue = xoaNguoiThue,
        super(NguoiThueInitial()) {
    on<NguoiThueStarted>(_onNguoiThueStarted);
    on<ThemNguoiThueRequested>(_onThemNguoiThueRequested);
    on<UpdateNguoiThueRequested>(_onUpdateNguoiThueRequested);
    on<XoaNguoiThueRequested>(_onXoaNguoiThueRequested);
    on<_NguoiThueDataUpdated>((event, emit) {
      _items = event.items;
      emit(NguoiThueLoaded(_items));
    });
    on<_NguoiThueDataError>((event, emit) => emit(NguoiThueError(event.message)));
  }

  Future<void> _onNguoiThueStarted(
      NguoiThueStarted event, Emitter<NguoiThueState> emit) async {
    emit(NguoiThueLoading());
    await _nguoiThueSub?.cancel();
    _nguoiThueSub = _watchNguoiThueList(event.chuNhaId).listen(
      (items) => add(_NguoiThueDataUpdated(items)),
      onError: (error) => add(_NguoiThueDataError(error.toString())),
    );
  }

  Future<void> _onThemNguoiThueRequested(
      ThemNguoiThueRequested event, Emitter<NguoiThueState> emit) async {
    emit(NguoiThueActionLoading());
    try {
      final nguoiThueToSave = event.nguoiThue.copyWith(
        phongId: event.phongId,
      );
      await _themNguoiThue(nguoiThueToSave, phongId: event.phongId);
      emit(NguoiThueActionSuccess());
      if (_items.isNotEmpty) emit(NguoiThueLoaded(_items));
    } catch (e) {
      emit(NguoiThueActionFailure(e.toString()));
      if (_items.isNotEmpty) emit(NguoiThueLoaded(_items));
    }
  }

  Future<void> _onUpdateNguoiThueRequested(
      UpdateNguoiThueRequested event, Emitter<NguoiThueState> emit) async {
    emit(NguoiThueActionLoading());
    try {
      final nguoiThueToSave = event.nguoiThue.copyWith(
        phongId: event.newPhongId,
      );
      await _updateNguoiThue(
        nguoiThueToSave,
        oldPhongId: event.nguoiThue.phongId,
        newPhongId: event.newPhongId,
      );
      emit(NguoiThueActionSuccess());
      if (_items.isNotEmpty) emit(NguoiThueLoaded(_items));
    } catch (e) {
      emit(NguoiThueActionFailure(e.toString()));
      if (_items.isNotEmpty) emit(NguoiThueLoaded(_items));
    }
  }

  Future<void> _onXoaNguoiThueRequested(
      XoaNguoiThueRequested event, Emitter<NguoiThueState> emit) async {
    emit(NguoiThueActionLoading());
    try {
      await _xoaNguoiThue(event.nguoiThueId, currentPhongId: event.currentPhongId);
      emit(NguoiThueActionSuccess());
      if (_items.isNotEmpty) emit(NguoiThueLoaded(_items));
    } catch (e) {
      emit(NguoiThueActionFailure(e.toString()));
      if (_items.isNotEmpty) emit(NguoiThueLoaded(_items));
    }
  }

  @override
  Future<void> close() {
    _nguoiThueSub?.cancel();
    return super.close();
  }
}

// Internal private events
class _NguoiThueDataUpdated extends NguoiThueEvent {
  final List<NguoiThueEntity> items;
  const _NguoiThueDataUpdated(this.items);
}

class _NguoiThueDataError extends NguoiThueEvent {
  final String message;
  const _NguoiThueDataError(this.message);
}
