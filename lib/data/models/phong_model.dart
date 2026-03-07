import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/phong_entity.dart';

class PhongModel extends PhongEntity {
  const PhongModel({
    required super.id,
    required super.tenPhong,
    required super.nhaTroId,
    required super.chuNhaId,
    super.bangGiaId,
    super.khachThue = const [],
    super.chiSoDienHienTai,
    super.chiSoNuocHienTai,
    super.trangThai = PhongTrangThai.trong,
    super.moTa,
    super.createdAt,
  });

  factory PhongModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PhongModel(
      id: doc.id,
      tenPhong: data['tenPhong'] as String? ?? '',
      nhaTroId: data['nhaTroId'] as String? ?? '',
      chuNhaId: data['chuNhaId'] as String? ?? '',
      bangGiaId: data['bangGiaId'] as String?,
      khachThue: List<String>.from(data['khachThue'] ?? []),
      chiSoDienHienTai: (data['chiSoDienHienTai'] as num?)?.toDouble(),
      chiSoNuocHienTai: (data['chiSoNuocHienTai'] as num?)?.toDouble(),
      trangThai: PhongTrangThai.fromValue(data['trangThai'] as int? ?? 0),
      moTa: data['moTa'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tenPhong': tenPhong,
      'nhaTroId': nhaTroId,
      'chuNhaId': chuNhaId,
      'bangGiaId': bangGiaId,
      'khachThue': khachThue,
      'chiSoDienHienTai': chiSoDienHienTai,
      'chiSoNuocHienTai': chiSoNuocHienTai,
      'trangThai': trangThai.value,
      'moTa': moTa,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  PhongEntity toEntity() {
    return PhongEntity(
      id: id,
      tenPhong: tenPhong,
      nhaTroId: nhaTroId,
      chuNhaId: chuNhaId,
      bangGiaId: bangGiaId,
      khachThue: khachThue,
      chiSoDienHienTai: chiSoDienHienTai,
      chiSoNuocHienTai: chiSoNuocHienTai,
      trangThai: trangThai,
      moTa: moTa,
      createdAt: createdAt,
    );
  }
}
