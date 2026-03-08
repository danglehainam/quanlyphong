import '../repositories/bang_gia_repository.dart';
import '../entities/bang_gia_entity.dart';

class GetBangGiaByIdUseCase {
  final BangGiaRepository repository;

  GetBangGiaByIdUseCase(this.repository);

  Future<BangGiaEntity?> call(String id) {
    return repository.getBangGiaById(id);
  }
}
