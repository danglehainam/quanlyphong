import '../entities/bang_gia_entity.dart';
import '../repositories/bang_gia_repository.dart';

class ThemBangGiaUseCase {
  final BangGiaRepository repository;

  ThemBangGiaUseCase(this.repository);

  Future<String> call(BangGiaEntity bangGia) {
    return repository.themBangGia(bangGia);
  }
}
