import '../entities/nha_tro_entity.dart';
import '../entities/phong_entity.dart';

abstract class PhongRepository {
  Stream<List<NhaTroEntity>> watchNhaTroList(String chuNhaId);
  Stream<List<PhongEntity>> watchPhongByNhaTro(String nhaTroId);
  Future<void> createNhaTroWithPhong(String tenNhaTro, String diaChi, int soLuongPhong, String chuNhaId);
}
