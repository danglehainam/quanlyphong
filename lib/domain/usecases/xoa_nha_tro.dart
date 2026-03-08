import '../repositories/phong_repository.dart';

class XoaNhaTroUseCase {
  final PhongRepository repository;

  XoaNhaTroUseCase(this.repository);

  Future<void> call(String nhaTroId) {
    return repository.deleteNhaTroWithPhong(nhaTroId);
  }
}
