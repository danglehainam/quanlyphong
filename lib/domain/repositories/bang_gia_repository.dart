import '../entities/bang_gia_entity.dart';

abstract class BangGiaRepository {
  Stream<List<BangGiaEntity>> watchBangGiaList(String chuNhaId);
  Future<String> themBangGia(BangGiaEntity bangGia);
  Future<void> xoaBangGia(String id);
  Future<void> updateBangGia(BangGiaEntity bangGia);
}
