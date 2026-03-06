import '../repositories/phong_repository.dart';

class ThemNhaTroUseCase {
  final PhongRepository repository;

  ThemNhaTroUseCase(this.repository);

  Future<void> call({
    required String tenNhaTro,
    required String diaChi,
    required int soLuongPhong,
    required String chuNhaId,
  }) {
    return repository.createNhaTroWithPhong(tenNhaTro, diaChi, soLuongPhong, chuNhaId);
  }
}
