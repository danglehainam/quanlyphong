import '../entities/phong_entity.dart';
import '../repositories/phong_repository.dart';

class WatchPhongListUseCase {
  final PhongRepository _repository;

  WatchPhongListUseCase(this._repository);

  Stream<List<PhongEntity>> call(String nhaTroId, String chuNhaId) {
    return _repository.watchPhongByNhaTro(nhaTroId, chuNhaId);
  }
}
