import '../entities/bang_gia_entity.dart';

abstract class BangGiaRepository {
  Stream<List<BangGiaEntity>> watchBangGiaList(String chuNhaId);
  Future<void> themBangGia(BangGiaEntity bangGia);
}
