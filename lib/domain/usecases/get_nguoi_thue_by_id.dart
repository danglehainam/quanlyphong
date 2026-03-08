import '../repositories/nguoi_thue_repository.dart';
import '../entities/nguoi_thue_entity.dart';

class GetNguoiThueByIdUseCase {
  final NguoiThueRepository repository;

  GetNguoiThueByIdUseCase(this.repository);

  Future<NguoiThueEntity?> call(String nguoiThueId) {
    return repository.getNguoiThueById(nguoiThueId);
  }
}
