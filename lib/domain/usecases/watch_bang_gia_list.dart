import '../entities/bang_gia_entity.dart';
import '../repositories/bang_gia_repository.dart';

class WatchBangGiaListUseCase {
  final BangGiaRepository repository;

  WatchBangGiaListUseCase(this.repository);

  Stream<List<BangGiaEntity>> call(String chuNhaId) {
    return repository.watchBangGiaList(chuNhaId);
  }
}
