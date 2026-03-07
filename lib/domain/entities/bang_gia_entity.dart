class BangGiaEntity {
  final String id;
  final String tenBangGia;
  final String chuNhaId;
  final int giaThue;
  
  // Điện
  final int giaDien;
  final int cachTinhDien; // 0 = VND/kWh, 1 = VND/person, 2 = manual
  
  // Nước
  final int giaNuoc;
  final int cachTinhNuoc; // 0 = VND/m3, 1 = VND/person, 2 = manual
  
  // Internet
  final int giaInternet;
  final int cachTinhInternet; // 0 = VND/room, 1 = VND/person
  
  // Khác
  final int? chiPhiKhac;
  final String? ghiChu;

  BangGiaEntity({
    required this.id,
    required this.tenBangGia,
    required this.chuNhaId,
    required this.giaThue,
    required this.giaDien,
    required this.cachTinhDien,
    required this.giaNuoc,
    required this.cachTinhNuoc,
    required this.giaInternet,
    required this.cachTinhInternet,
    this.chiPhiKhac,
    this.ghiChu,
  });
}
