import '../repositories/phong_repository.dart';
import '../entities/phong_entity.dart';
import '../entities/nha_tro_entity.dart';

class RoomDetail {
  final PhongEntity phong;
  final NhaTroEntity? nhaTro;

  RoomDetail({required this.phong, this.nhaTro});
}

class GetPhongUseCase {
  final PhongRepository repository;

  GetPhongUseCase(this.repository);

  Future<RoomDetail?> call(String phongId) async {
    final phong = await repository.getPhongById(phongId);
    if (phong == null) return null;

    final nhaTro = await repository.getNhaTroById(phong.nhaTroId);
    return RoomDetail(phong: phong, nhaTro: nhaTro);
  }
}
