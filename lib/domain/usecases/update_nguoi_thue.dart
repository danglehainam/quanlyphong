import '../repositories/nguoi_thue_repository.dart';
import '../repositories/phong_repository.dart';
import '../entities/nguoi_thue_entity.dart';

class UpdateNguoiThueUseCase {
  final NguoiThueRepository repository;
  final PhongRepository phongRepository;

  UpdateNguoiThueUseCase(this.repository, this.phongRepository);

  Future<void> call(NguoiThueEntity nguoiThue, {String? oldPhongId, String? newPhongId}) async {
    // 1. Update renter record (including new phongId if any)
    await repository.updateNguoiThue(nguoiThue);

    // 2. Handle room transitions if changed
    if (oldPhongId != newPhongId) {
      // Remove from old room
      if (oldPhongId != null) {
        await phongRepository.removeKhachThueFromPhong(oldPhongId, nguoiThue.id);
      }
      // Add to new room
      if (newPhongId != null) {
        await phongRepository.addKhachThueToPhong(newPhongId, nguoiThue.id);
      }
    }
  }
}
