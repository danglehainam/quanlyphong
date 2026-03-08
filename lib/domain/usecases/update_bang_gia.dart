import '../entities/bang_gia_entity.dart';
import '../repositories/bang_gia_repository.dart';

class UpdateBangGiaUseCase {
  final BangGiaRepository repository;

  UpdateBangGiaUseCase(this.repository);

  Future<void> call(BangGiaEntity bangGia) {
    return repository.updateBangGia(bangGia);
  }
}
