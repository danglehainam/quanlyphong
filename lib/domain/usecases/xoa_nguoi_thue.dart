import '../repositories/nguoi_thue_repository.dart';
import '../repositories/phong_repository.dart';

class XoaNguoiThueUseCase {
  final NguoiThueRepository repository;
  final PhongRepository phongRepository;

  XoaNguoiThueUseCase(this.repository, this.phongRepository);

  Future<void> call(String nguoiThueId, {String? currentPhongId}) async {
    // 1. Delete the renter record
    await repository.xoaNguoiThue(nguoiThueId);

    // 2. Clean up room assignment if exists
    if (currentPhongId != null) {
      await phongRepository.removeKhachThueFromPhong(currentPhongId, nguoiThueId);
    }
  }
}
