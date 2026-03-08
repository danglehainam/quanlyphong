import '../../domain/entities/nha_tro_entity.dart';
import '../../domain/entities/phong_entity.dart';
import '../../domain/repositories/phong_repository.dart';
import '../datasources/remote/phong_remote_data_source.dart';
import '../models/nha_tro_model.dart';

class PhongRepositoryImpl implements PhongRepository {
  final PhongRemoteDataSource remoteDataSource;

  PhongRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<NhaTroEntity>> watchNhaTroList(String chuNhaId) {
    return remoteDataSource
        .watchNhaTroList(chuNhaId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Stream<List<PhongEntity>> watchTatCaPhong(String chuNhaId) {
    return remoteDataSource
        .watchTatCaPhong(chuNhaId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Stream<List<PhongEntity>> watchPhongByNhaTro(String nhaTroId, String chuNhaId) {
    return remoteDataSource
        .watchPhongByNhaTro(nhaTroId, chuNhaId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> createNhaTroWithPhong(String tenNhaTro, String diaChi, int soLuongPhong, String chuNhaId) async {
    return remoteDataSource.createNhaTroWithPhong(tenNhaTro, diaChi, soLuongPhong, chuNhaId);
  }

  @override
  Future<void> updateBangGiaChoPhongList(List<String> phongIds, String bangGiaId) async {
    return remoteDataSource.updateBangGiaChoPhongList(phongIds, bangGiaId);
  }
  @override
  Future<void> xoaBangGiaKhoiTatCaPhong(String bangGiaId, String chuNhaId) async {
    return remoteDataSource.xoaBangGiaKhoiTatCaPhong(bangGiaId, chuNhaId);
  }
  @override
  Future<void> updateNhaTro(NhaTroEntity nhaTro) {
    return remoteDataSource.updateNhaTro(NhaTroModel.fromEntity(nhaTro));
  }

  @override
  Future<void> deleteNhaTroWithPhong(String nhaTroId) {
    return remoteDataSource.deleteNhaTroWithPhong(nhaTroId);
  }

  @override
  Future<void> addKhachThueToPhong(String phongId, String nguoiThueId) {
    return remoteDataSource.addKhachThueToPhong(phongId, nguoiThueId);
  }

  @override
  Future<void> removeKhachThueFromPhong(String phongId, String nguoiThueId) {
    return remoteDataSource.removeKhachThueFromPhong(phongId, nguoiThueId);
  }

  @override
  Future<PhongEntity?> getPhongById(String phongId) async {
    final model = await remoteDataSource.getPhongById(phongId);
    return model?.toEntity();
  }

  @override
  Future<NhaTroEntity?> getNhaTroById(String nhaTroId) async {
    final model = await remoteDataSource.getNhaTroById(nhaTroId);
    return model?.toEntity();
  }
}
