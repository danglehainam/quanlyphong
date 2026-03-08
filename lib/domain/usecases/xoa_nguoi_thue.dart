import '../repositories/nguoi_thue_repository.dart';

class XoaNguoiThueUseCase {
  final NguoiThueRepository repository;

  XoaNguoiThueUseCase(this.repository);

  Future<void> call(String nguoiThueId) {
    return repository.xoaNguoiThue(nguoiThueId);
  }
}
