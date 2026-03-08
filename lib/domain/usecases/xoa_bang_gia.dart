import '../repositories/bang_gia_repository.dart';
import '../repositories/phong_repository.dart';

class XoaBangGiaUseCase {
  final BangGiaRepository bangGiaRepository;
  final PhongRepository phongRepository;

  XoaBangGiaUseCase({
    required this.bangGiaRepository,
    required this.phongRepository,
  });

  Future<void> call(String bangGiaId, String chuNhaId) async {
    // 1. Xóa bảng giá
    await bangGiaRepository.xoaBangGia(bangGiaId);
    
    // 2. Xóa ID bảng giá khỏi tất cả các phòng đang áp dụng
    await phongRepository.xoaBangGiaKhoiTatCaPhong(bangGiaId, chuNhaId);
  }
}
