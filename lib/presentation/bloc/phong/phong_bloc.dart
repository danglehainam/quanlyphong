import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'phong_event.dart';
import 'phong_state.dart';
import '../../../domain/entities/nha_tro_entity.dart';
import '../../../domain/entities/phong_entity.dart';
import '../../../domain/usecases/watch_nha_tro_list.dart';
import '../../../domain/usecases/watch_phong_list.dart';

class PhongBloc extends Bloc<PhongEvent, PhongState> {
  final WatchNhaTroListUseCase _watchNhaTroList;
  final WatchPhongListUseCase _watchPhongList;

  StreamSubscription? _nhaTroSub;
  final Map<String, StreamSubscription> _phongSubs = {};
  final Map<String, List<PhongEntity>> _phongMap = {};
  List<NhaTroEntity> _nhaTroList = [];

  PhongBloc({
    required WatchNhaTroListUseCase watchNhaTroList,
    required WatchPhongListUseCase watchPhongList,
  })  : _watchNhaTroList = watchNhaTroList,
        _watchPhongList = watchPhongList,
        super(PhongInitial()) {
    on<PhongStarted>(_onPhongStarted);
    on<_PhongDataUpdated>((event, emit) {
      if (_nhaTroList.isNotEmpty) {
        emit(_buildLoaded());
      }
    });
  }

  Future<void> _onPhongStarted(
      PhongStarted event, Emitter<PhongState> emit) async {
    emit(PhongLoading());

    await _nhaTroSub?.cancel();
    for (final sub in _phongSubs.values) {
      await sub.cancel();
    }
    _phongSubs.clear();
    _phongMap.clear();

    await emit.forEach<List<NhaTroEntity>>(
      _watchNhaTroList(event.chuNhaId),
      onData: (nhaTroList) {
        _nhaTroList = nhaTroList;

        // Subscribe phong stream cho các nhà trọ mới
        for (final nhaTro in nhaTroList) {
          if (!_phongSubs.containsKey(nhaTro.id)) {
            _phongSubs[nhaTro.id] = _watchPhongList(nhaTro.id, event.chuNhaId).listen((phongList) {
              _phongMap[nhaTro.id] = phongList;
              add(_PhongDataUpdated());
            });
          }
        }

        // Gỡ subscription cho các nhà trọ đã bị xóa
        final currentIds = nhaTroList.map((e) => e.id).toSet();
        final removedIds = _phongSubs.keys.where((id) => !currentIds.contains(id)).toList();
        for (final id in removedIds) {
          _phongSubs.remove(id)?.cancel();
          _phongMap.remove(id);
        }

        return _buildLoaded();
      },
      onError: (error, stackTrace) {
        // ignore: avoid_print
        print('[PhongBloc] Lỗi stream nhà trọ: $error');
        return const PhongError('Không thể tải dữ liệu. Vui lòng thử lại.');
      },
    );
  }

  PhongLoaded _buildLoaded() {
    final items = _nhaTroList.map((nhaTro) {
      return NhaTroWithPhong(
        nhaTro: nhaTro,
        phongList: _phongMap[nhaTro.id] ?? [],
      );
    }).toList();
    return PhongLoaded(items);
  }

  @override
  Future<void> close() async {
    await _nhaTroSub?.cancel();
    for (final sub in _phongSubs.values) {
      await sub.cancel();
    }
    return super.close();
  }
}

// Internal event để trigger rebuild khi phong data thay đổi
class _PhongDataUpdated extends PhongEvent {}
