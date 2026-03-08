import '../repositories/nguoi_thue_repository.dart';
import '../repositories/phong_repository.dart';
import '../entities/nguoi_thue_entity.dart';

class ThemNguoiThueUseCase {
  final NguoiThueRepository repository;
  final PhongRepository phongRepository;

  ThemNguoiThueUseCase(this.repository, this.phongRepository);

  Future<void> call(NguoiThueEntity nguoiThue, {String? phongId}) async {
    final nguoiThueId = await repository.themNguoiThue(nguoiThue);
    if (phongId != null) {
      await phongRepository.addKhachThueToPhong(phongId, nguoiThueId);
    }
  }
}
