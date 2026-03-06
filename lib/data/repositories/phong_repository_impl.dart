import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/nha_tro_entity.dart';
import '../../domain/entities/phong_entity.dart';
import '../../domain/repositories/phong_repository.dart';

class PhongRepositoryImpl implements PhongRepository {
  final FirebaseFirestore _firestore;

  PhongRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<NhaTroEntity>> watchNhaTroList(String chuNhaId) {
    return _firestore
        .collection('nha_tro')
        .where('chuNhaId', isEqualTo: chuNhaId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return NhaTroEntity(
                id: doc.id,
                tenNhaTro: data['tenNhaTro'] ?? '',
                diaChi: data['diaChi'] ?? '',
                chuNhaId: data['chuNhaId'] ?? '',
                createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
              );
            }).toList());
  }

  @override
  Stream<List<PhongEntity>> watchPhongByNhaTro(String nhaTroId) {
    return _firestore
        .collection('phong')
        .where('nhaTroId', isEqualTo: nhaTroId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return PhongEntity(
                id: doc.id,
                tenPhong: data['tenPhong'] ?? '',
                nhaTroId: data['nhaTroId'] ?? '',
                chuNhaId: data['chuNhaId'] ?? '',
                bangGiaId: data['bangGiaId'],
                khachThue: List<String>.from(data['khachThue'] ?? []),
                chiSoDienHienTai: (data['chiSoDienHienTai'] as num?)?.toDouble(),
                chiSoNuocHienTai: (data['chiSoNuocHienTai'] as num?)?.toDouble(),
                trangThai: PhongTrangThai.fromValue(data['trangThai'] ?? 0),
                moTa: data['moTa'],
                createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
              );
            }).toList());
  }
}
