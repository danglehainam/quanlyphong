import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/nha_tro_model.dart';
import '../../models/phong_model.dart';

abstract class PhongRemoteDataSource {
  Stream<List<NhaTroModel>> watchNhaTroList(String chuNhaId);
  Stream<List<PhongModel>> watchPhongByNhaTro(String nhaTroId, String chuNhaId);
  Future<void> createNhaTroWithPhong(String tenNhaTro, String diaChi, int soLuongPhong, String chuNhaId);
}

class PhongRemoteDataSourceImpl implements PhongRemoteDataSource {
  final FirebaseFirestore _firestore;

  PhongRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<NhaTroModel>> watchNhaTroList(String chuNhaId) {
    return _firestore
        .collection('nha_tro')
        .where('chuNhaId', isEqualTo: chuNhaId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return NhaTroModel.fromFirestore(doc);
            }).toList());
  }

  @override
  Stream<List<PhongModel>> watchPhongByNhaTro(String nhaTroId, String chuNhaId) {
    return _firestore
        .collection('phong')
        .where('nhaTroId', isEqualTo: nhaTroId)
        .where('chuNhaId', isEqualTo: chuNhaId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return PhongModel.fromFirestore(doc);
            }).toList()..sort((a, b) {
              final numA = int.tryParse(a.tenPhong);
              final numB = int.tryParse(b.tenPhong);
              if (numA != null && numB != null) {
                return numA.compareTo(numB);
              }
              return a.tenPhong.compareTo(b.tenPhong);
            }));
  }

  @override
  Future<void> createNhaTroWithPhong(String tenNhaTro, String diaChi, int soLuongPhong, String chuNhaId) async {
    final batch = _firestore.batch();
    
    // 1. Tạo document nhà trọ mới
    final nhaTroRef = _firestore.collection('nha_tro').doc();
    
    final nhaTroModel = NhaTroModel(
      id: nhaTroRef.id,
      tenNhaTro: tenNhaTro,
      diaChi: diaChi,
      chuNhaId: chuNhaId,
    );
    
    batch.set(nhaTroRef, nhaTroModel.toFirestore());

    // 2. Tạo N document phòng
    for (int i = 1; i <= soLuongPhong; i++) {
      final phongRef = _firestore.collection('phong').doc();
      final phongModel = PhongModel(
        id: phongRef.id,
        tenPhong: i.toString(),
        nhaTroId: nhaTroRef.id,
        chuNhaId: chuNhaId,
      );
      
      batch.set(phongRef, phongModel.toFirestore());
    }

    // Thực thi batch
    await batch.commit();
  }
}
