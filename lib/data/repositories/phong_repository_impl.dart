import '../../domain/entities/nha_tro_entity.dart';
import '../../domain/entities/phong_entity.dart';
import '../../domain/repositories/phong_repository.dart';
import '../datasources/remote/phong_remote_data_source.dart';

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
  Stream<List<PhongEntity>> watchPhongByNhaTro(String nhaTroId, String chuNhaId) {
    return remoteDataSource
        .watchPhongByNhaTro(nhaTroId, chuNhaId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> createNhaTroWithPhong(String tenNhaTro, String diaChi, int soLuongPhong, String chuNhaId) async {
    return remoteDataSource.createNhaTroWithPhong(tenNhaTro, diaChi, soLuongPhong, chuNhaId);
  }
}
