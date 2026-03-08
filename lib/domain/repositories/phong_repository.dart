import '../entities/nha_tro_entity.dart';
import '../entities/phong_entity.dart';

abstract class PhongRepository {
  Stream<List<NhaTroEntity>> watchNhaTroList(String chuNhaId);
  Stream<List<PhongEntity>> watchTatCaPhong(String chuNhaId);
  Stream<List<PhongEntity>> watchPhongByNhaTro(String nhaTroId, String chuNhaId);
  Future<void> createNhaTroWithPhong(String tenNhaTro, String diaChi, int soLuongPhong, String chuNhaId);
  Future<void> updateNhaTro(NhaTroEntity nhaTro);
  Future<void> deleteNhaTroWithPhong(String nhaTroId);
  Future<void> updateBangGiaChoPhongList(List<String> phongIds, String bangGiaId);
  Future<void> xoaBangGiaKhoiTatCaPhong(String bangGiaId, String chuNhaId);
  Future<void> addKhachThueToPhong(String phongId, String nguoiThueId);
  Future<void> removeKhachThueFromPhong(String phongId, String nguoiThueId);
}
