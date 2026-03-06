enum PhongTrangThai {
  trong(0),
  daThue(1),
  baoTri(2);

  final int value;
  const PhongTrangThai(this.value);

  static PhongTrangThai fromValue(int value) {
    return PhongTrangThai.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PhongTrangThai.trong,
    );
  }
}

class PhongEntity {
  final String id;
  final String tenPhong;
  final String nhaTroId;
  final String chuNhaId;
  final String? bangGiaId;
  final List<String> khachThue;
  final double? chiSoDienHienTai;
  final double? chiSoNuocHienTai;
  final PhongTrangThai trangThai;
  final String? moTa;
  final DateTime? createdAt;

  const PhongEntity({
    required this.id,
    required this.tenPhong,
    required this.nhaTroId,
    required this.chuNhaId,
    this.bangGiaId,
    this.khachThue = const [],
    this.chiSoDienHienTai,
    this.chiSoNuocHienTai,
    this.trangThai = PhongTrangThai.trong,
    this.moTa,
    this.createdAt,
  });
}
