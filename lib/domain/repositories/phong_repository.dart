import '../entities/nha_tro_entity.dart';
import '../entities/phong_entity.dart';

abstract class PhongRepository {
  Stream<List<NhaTroEntity>> watchNhaTroList(String chuNhaId);
  Stream<List<PhongEntity>> watchTatCaPhong(String chuNhaId);
  Stream<List<PhongEntity>> watchPhongByNhaTro(String nhaTroId, String chuNhaId);
  Future<void> createNhaTroWithPhong(String tenNhaTro, String diaChi, int soLuongPhong, String chuNhaId);
  Future<void> updateBangGiaChoPhongList(List<String> phongIds, String bangGiaId);
}
