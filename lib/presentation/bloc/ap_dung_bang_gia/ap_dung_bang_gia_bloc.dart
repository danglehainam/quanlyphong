import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/watch_nha_tro_list.dart';
import '../../../domain/usecases/watch_tat_ca_phong.dart';
import '../../../domain/usecases/update_bang_gia_cho_phong_list.dart';
import 'ap_dung_bang_gia_event.dart';
import 'ap_dung_bang_gia_state.dart';
import 'package:rxdart/rxdart.dart';

class ApDungBangGiaBloc extends Bloc<ApDungBangGiaEvent, ApDungBangGiaState> {
  final WatchNhaTroListUseCase watchNhaTroList;
  final WatchTatCaPhongUseCase watchTatCaPhong;
  final UpdateBangGiaChoPhongListUseCase updateBangGiaChoPhongList;

  ApDungBangGiaBloc({
    required this.watchNhaTroList,
    required this.watchTatCaPhong,
    required this.updateBangGiaChoPhongList,
  }) : super(ApDungBangGiaLoading()) {
    on<ApDungBangGiaStarted>(_onStarted);
    on<TogglePhongSelection>(_onToggleSelection);
    on<SubmitApDungBangGia>(_onSubmit);
  }

  Future<void> _onStarted(
    ApDungBangGiaStarted event,
    Emitter<ApDungBangGiaState> emit,
  ) async {
    emit(ApDungBangGiaLoading());
    try {
      final stream = Rx.combineLatest2(
        watchNhaTroList(event.chuNhaId),
        watchTatCaPhong(event.chuNhaId),
        (nhaTroList, phongList) => ApDungBangGiaLoaded(
          nhaTroList: nhaTroList,
          phongList: phongList,
        ),
      );

      await emit.forEach<ApDungBangGiaLoaded>(
        stream,
        onData: (data) {
          if (state is ApDungBangGiaLoaded) {
            final currentState = state as ApDungBangGiaLoaded;
            return data.copyWith(selectedPhongIds: currentState.selectedPhongIds);
          }
          return data;
        },
        onError: (error, _) => ApDungBangGiaFailure(error.toString()),
      );
    } catch (e) {
      emit(ApDungBangGiaFailure(e.toString()));
    }
  }

  void _onToggleSelection(
    TogglePhongSelection event,
    Emitter<ApDungBangGiaState> emit,
  ) {
    if (state is ApDungBangGiaLoaded) {
      final currentState = state as ApDungBangGiaLoaded;
      final newSelectedIds = Set<String>.from(currentState.selectedPhongIds);
      
      if (newSelectedIds.contains(event.phongId)) {
        newSelectedIds.remove(event.phongId);
      } else {
        newSelectedIds.add(event.phongId);
      }
      
      emit(currentState.copyWith(selectedPhongIds: newSelectedIds));
    }
  }

  Future<void> _onSubmit(
    SubmitApDungBangGia event,
    Emitter<ApDungBangGiaState> emit,
  ) async {
    if (state is! ApDungBangGiaLoaded) return;
    final currentState = state as ApDungBangGiaLoaded;
    
    if (currentState.selectedPhongIds.isEmpty) {
      emit(const ApDungBangGiaFailure('Vui lòng chọn ít nhất 1 phòng để áp dụng'));
      emit(currentState); // Restore state
      return;
    }

    emit(ApDungBangGiaSubmitting());
    try {
      await updateBangGiaChoPhongList(
        currentState.selectedPhongIds.toList(),
        event.bangGiaId,
      );
      emit(ApDungBangGiaSuccess());
      // Optionally restore state with cleared selections if dialog stays open
      // emit(currentState.copyWith(selectedPhongIds: {})); 
    } catch (e) {
      emit(ApDungBangGiaFailure('Lỗi khi áp dụng bảng giá: ${e.toString()}'));
      emit(currentState); // Restore state
    }
  }
}
