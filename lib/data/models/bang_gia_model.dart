import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/bang_gia_entity.dart';

class BangGiaModel {
  final String id;
  final String tenBangGia;
  final String chuNhaId;
  final int giaThue;
  final int giaDien;
  final int cachTinhDien;
  final int giaNuoc;
  final int cachTinhNuoc;
  final int giaInternet;
  final int cachTinhInternet;
  final int? chiPhiKhac;
  final String? ghiChu;

  const BangGiaModel({
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

  factory BangGiaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BangGiaModel(
      id: doc.id,
      tenBangGia: data['tenBangGia'] as String? ?? '',
      chuNhaId: data['chuNhaId'] as String? ?? '',
      giaThue: (data['giaThue'] as num? ?? 0).toInt(),
      giaDien: (data['giaDien'] as num? ?? 0).toInt(),
      cachTinhDien: (data['cachTinhDien'] as num? ?? 0).toInt(),
      giaNuoc: (data['giaNuoc'] as num? ?? 0).toInt(),
      cachTinhNuoc: (data['cachTinhNuoc'] as num? ?? 0).toInt(),
      giaInternet: (data['giaInternet'] as num? ?? 0).toInt(),
      cachTinhInternet: (data['cachTinhInternet'] as num? ?? 0).toInt(),
      chiPhiKhac: (data['chiPhiKhac'] as num?)?.toInt(),
      ghiChu: data['ghiChu'] as String?,
    );
  }

  factory BangGiaModel.fromEntity(BangGiaEntity entity) {
    return BangGiaModel(
      id: entity.id,
      tenBangGia: entity.tenBangGia,
      chuNhaId: entity.chuNhaId,
      giaThue: entity.giaThue,
      giaDien: entity.giaDien,
      cachTinhDien: entity.cachTinhDien,
      giaNuoc: entity.giaNuoc,
      cachTinhNuoc: entity.cachTinhNuoc,
      giaInternet: entity.giaInternet,
      cachTinhInternet: entity.cachTinhInternet,
      chiPhiKhac: entity.chiPhiKhac,
      ghiChu: entity.ghiChu,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tenBangGia': tenBangGia,
      'chuNhaId': chuNhaId,
      'giaThue': giaThue,
      'giaDien': giaDien,
      'cachTinhDien': cachTinhDien,
      'giaNuoc': giaNuoc,
      'cachTinhNuoc': cachTinhNuoc,
      'giaInternet': giaInternet,
      'cachTinhInternet': cachTinhInternet,
      'chiPhiKhac': chiPhiKhac,
      'ghiChu': ghiChu,
    };
  }

  BangGiaEntity toEntity() {
    return BangGiaEntity(
      id: id,
      tenBangGia: tenBangGia,
      chuNhaId: chuNhaId,
      giaThue: giaThue,
      giaDien: giaDien,
      cachTinhDien: cachTinhDien,
      giaNuoc: giaNuoc,
      cachTinhNuoc: cachTinhNuoc,
      giaInternet: giaInternet,
      cachTinhInternet: cachTinhInternet,
      chiPhiKhac: chiPhiKhac,
      ghiChu: ghiChu,
    );
  }
}
