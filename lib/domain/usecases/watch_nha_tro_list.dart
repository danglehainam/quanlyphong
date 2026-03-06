import '../entities/nha_tro_entity.dart';
import '../repositories/phong_repository.dart';

class WatchNhaTroListUseCase {
  final PhongRepository _repository;

  WatchNhaTroListUseCase(this._repository);

  Stream<List<NhaTroEntity>> call(String chuNhaId) {
    return _repository.watchNhaTroList(chuNhaId);
  }
}
