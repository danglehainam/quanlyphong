import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/nha_tro_entity.dart';

class NhaTroModel {
  final String id;
  final String tenNhaTro;
  final String diaChi;
  final String chuNhaId;
  final DateTime? createdAt;

  const NhaTroModel({
    required this.id,
    required this.tenNhaTro,
    required this.diaChi,
    required this.chuNhaId,
    this.createdAt,
  });

  factory NhaTroModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NhaTroModel(
      id: doc.id,
      tenNhaTro: data['tenNhaTro'] as String? ?? '',
      diaChi: data['diaChi'] as String? ?? '',
      chuNhaId: data['chuNhaId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory NhaTroModel.fromEntity(NhaTroEntity entity) {
    return NhaTroModel(
      id: entity.id,
      tenNhaTro: entity.tenNhaTro,
      diaChi: entity.diaChi,
      chuNhaId: entity.chuNhaId,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tenNhaTro': tenNhaTro,
      'diaChi': diaChi,
      'chuNhaId': chuNhaId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  NhaTroEntity toEntity() {
    return NhaTroEntity(
      id: id,
      tenNhaTro: tenNhaTro,
      diaChi: diaChi,
      chuNhaId: chuNhaId,
      createdAt: createdAt,
    );
  }
}
