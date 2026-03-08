import '../repositories/nguoi_thue_repository.dart';
import '../entities/nguoi_thue_entity.dart';

class WatchNguoiThueListUseCase {
  final NguoiThueRepository repository;

  WatchNguoiThueListUseCase(this.repository);

  Stream<List<NguoiThueEntity>> call(String chuNhaId) {
    return repository.watchNguoiThueList(chuNhaId);
  }
}
