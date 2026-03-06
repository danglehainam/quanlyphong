class NhaTroEntity {
  final String id;
  final String tenNhaTro;
  final String diaChi;
  final String chuNhaId;
  final DateTime? createdAt;

  const NhaTroEntity({
    required this.id,
    required this.tenNhaTro,
    required this.diaChi,
    required this.chuNhaId,
    this.createdAt,
  });
}
