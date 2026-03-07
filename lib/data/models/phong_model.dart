import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/phong_entity.dart';

class PhongModel {
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

  const PhongModel({
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

  factory PhongModel.fromEntity(PhongEntity entity) {
    return PhongModel(
      id: entity.id,
      tenPhong: entity.tenPhong,
      nhaTroId: entity.nhaTroId,
      chuNhaId: entity.chuNhaId,
      bangGiaId: entity.bangGiaId,
      khachThue: entity.khachThue,
      chiSoDienHienTai: entity.chiSoDienHienTai,
      chiSoNuocHienTai: entity.chiSoNuocHienTai,
      trangThai: entity.trangThai,
      moTa: entity.moTa,
      createdAt: entity.createdAt,
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
