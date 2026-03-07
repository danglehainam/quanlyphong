import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/nha_tro_entity.dart';

class NhaTroModel extends NhaTroEntity {
  const NhaTroModel({
    required super.id,
    required super.tenNhaTro,
    required super.diaChi,
    required super.chuNhaId,
    super.createdAt,
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
