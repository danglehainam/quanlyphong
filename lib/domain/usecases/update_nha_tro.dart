import '../entities/nha_tro_entity.dart';
import '../repositories/phong_repository.dart';

class UpdateNhaTroUseCase {
  final PhongRepository repository;

  UpdateNhaTroUseCase(this.repository);

  Future<void> call(NhaTroEntity nhaTro) {
    return repository.updateNhaTro(nhaTro);
  }
}
