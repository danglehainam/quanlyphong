import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/nguoi_thue_entity.dart';

class NguoiThueModel {
  final String id;
  final String hoTen;
  final String soDienThoai;
  final String? cccd;
  final DateTime? ngaySinh;
  final String? queQuan;
  final List<String> anhCCCD;
  final String chuNhaId;
  final DateTime? createdAt;
  final String? phongId;

  const NguoiThueModel({
    required this.id,
    required this.hoTen,
    required this.soDienThoai,
    this.cccd,
    this.ngaySinh,
    this.queQuan,
    this.anhCCCD = const [],
    required this.chuNhaId,
    this.createdAt,
    this.phongId,
  });

  factory NguoiThueModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NguoiThueModel(
      id: doc.id,
      hoTen: data['hoTen'] as String? ?? '',
      soDienThoai: data['soDienThoai'] as String? ?? '',
      cccd: data['cccd'] as String?,
      ngaySinh: (data['ngaySinh'] as Timestamp?)?.toDate(),
      queQuan: data['queQuan'] as String?,
      anhCCCD: List<String>.from(data['anhCCCD'] ?? []),
      chuNhaId: data['chuNhaId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      phongId: data['phongId'] as String?,
    );
  }

  factory NguoiThueModel.fromEntity(NguoiThueEntity entity) {
    return NguoiThueModel(
      id: entity.id,
      hoTen: entity.hoTen,
      soDienThoai: entity.soDienThoai,
      cccd: entity.cccd,
      ngaySinh: entity.ngaySinh,
      queQuan: entity.queQuan,
      anhCCCD: entity.anhCCCD,
      chuNhaId: entity.chuNhaId,
      createdAt: entity.createdAt,
      phongId: entity.phongId,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'hoTen': hoTen,
      'soDienThoai': soDienThoai,
      'cccd': cccd,
      'ngaySinh': ngaySinh != null ? Timestamp.fromDate(ngaySinh!) : null,
      'queQuan': queQuan,
      'anhCCCD': anhCCCD,
      'chuNhaId': chuNhaId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'phongId': phongId,
    };
  }

  NguoiThueEntity toEntity() {
    return NguoiThueEntity(
      id: id,
      hoTen: hoTen,
      soDienThoai: soDienThoai,
      cccd: cccd,
      ngaySinh: ngaySinh,
      queQuan: queQuan,
      anhCCCD: anhCCCD,
      chuNhaId: chuNhaId,
      createdAt: createdAt,
      phongId: phongId,
    );
  }
}
