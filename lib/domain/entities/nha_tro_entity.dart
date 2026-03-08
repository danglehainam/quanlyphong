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

  NhaTroEntity copyWith({
    String? id,
    String? tenNhaTro,
    String? diaChi,
    String? chuNhaId,
    DateTime? createdAt,
  }) {
    return NhaTroEntity(
      id: id ?? this.id,
      tenNhaTro: tenNhaTro ?? this.tenNhaTro,
      diaChi: diaChi ?? this.diaChi,
      chuNhaId: chuNhaId ?? this.chuNhaId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
