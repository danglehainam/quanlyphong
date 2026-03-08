import '../entities/phong_entity.dart';
import '../repositories/phong_repository.dart';

class WatchTatCaPhongUseCase {
  final PhongRepository _repository;

  WatchTatCaPhongUseCase(this._repository);

  Stream<List<PhongEntity>> call(String chuNhaId) {
    return _repository.watchTatCaPhong(chuNhaId);
  }
}
