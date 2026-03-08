import '../repositories/nguoi_thue_repository.dart';
import '../entities/nguoi_thue_entity.dart';

class UpdateNguoiThueUseCase {
  final NguoiThueRepository repository;

  UpdateNguoiThueUseCase(this.repository);

  Future<void> call(NguoiThueEntity nguoiThue) {
    return repository.updateNguoiThue(nguoiThue);
  }
}
