import '../../domain/entities/bang_gia_entity.dart';
import '../../domain/repositories/bang_gia_repository.dart';
import '../datasources/remote/bang_gia_remote_data_source.dart';
import '../models/bang_gia_model.dart';

class BangGiaRepositoryImpl implements BangGiaRepository {
  final BangGiaRemoteDataSource remoteDataSource;

  BangGiaRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<BangGiaEntity>> watchBangGiaList(String chuNhaId) {
    return remoteDataSource.watchBangGiaList(chuNhaId).map(
          (models) => models.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Future<String> themBangGia(BangGiaEntity bangGia) {
    final model = BangGiaModel.fromEntity(bangGia);
    return remoteDataSource.themBangGia(model);
  }
  @override
  Future<void> xoaBangGia(String id) {
    return remoteDataSource.xoaBangGia(id);
  }

  @override
  Future<void> updateBangGia(BangGiaEntity bangGia) {
    return remoteDataSource.updateBangGia(BangGiaModel.fromEntity(bangGia));
  }
}
