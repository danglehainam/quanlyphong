import '../repositories/phong_repository.dart';

class UpdateBangGiaChoPhongListUseCase {
  final PhongRepository _repository;

  UpdateBangGiaChoPhongListUseCase(this._repository);

  Future<void> call(List<String> phongIds, String bangGiaId) {
    return _repository.updateBangGiaChoPhongList(phongIds, bangGiaId);
  }
}
