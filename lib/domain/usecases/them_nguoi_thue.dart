import '../repositories/nguoi_thue_repository.dart';
import '../entities/nguoi_thue_entity.dart';

class ThemNguoiThueUseCase {
  final NguoiThueRepository repository;

  ThemNguoiThueUseCase(this.repository);

  Future<void> call(NguoiThueEntity nguoiThue) {
    return repository.themNguoiThue(nguoiThue);
  }
}
