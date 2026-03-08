import '../entities/nguoi_thue_entity.dart';

abstract class NguoiThueRepository {
  Stream<List<NguoiThueEntity>> watchNguoiThueList(String chuNhaId);
  Future<String> themNguoiThue(NguoiThueEntity nguoiThue);
  Future<void> updateNguoiThue(NguoiThueEntity nguoiThue);
  Future<void> xoaNguoiThue(String nguoiThueId);
}
