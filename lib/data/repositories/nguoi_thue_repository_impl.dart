import '../../domain/entities/nguoi_thue_entity.dart';
import '../../domain/repositories/nguoi_thue_repository.dart';
import '../datasources/remote/nguoi_thue_remote_data_source.dart';
import '../models/nguoi_thue_model.dart';

class NguoiThueRepositoryImpl implements NguoiThueRepository {
  final NguoiThueRemoteDataSource remoteDataSource;

  NguoiThueRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<NguoiThueEntity>> watchNguoiThueList(String chuNhaId) {
    return remoteDataSource
        .watchNguoiThueList(chuNhaId)
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<String> themNguoiThue(NguoiThueEntity nguoiThue) {
    return remoteDataSource.themNguoiThue(NguoiThueModel.fromEntity(nguoiThue));
  }

  @override
  Future<void> updateNguoiThue(NguoiThueEntity nguoiThue) {
    return remoteDataSource.updateNguoiThue(NguoiThueModel.fromEntity(nguoiThue));
  }

  @override
  Future<void> xoaNguoiThue(String nguoiThueId) {
    return remoteDataSource.xoaNguoiThue(nguoiThueId);
  }
}
