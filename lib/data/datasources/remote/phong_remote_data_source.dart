import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/nha_tro_model.dart';
import '../../models/phong_model.dart';

abstract class PhongRemoteDataSource {
  Stream<List<NhaTroModel>> watchNhaTroList(String chuNhaId);
  Stream<List<PhongModel>> watchTatCaPhong(String chuNhaId);
  Stream<List<PhongModel>> watchPhongByNhaTro(String nhaTroId, String chuNhaId);
  Future<void> createNhaTroWithPhong(String tenNhaTro, String diaChi, int soLuongPhong, String chuNhaId);
  Future<void> updateNhaTro(NhaTroModel nhaTro);
  Future<void> deleteNhaTroWithPhong(String nhaTroId);
  Future<void> updateBangGiaChoPhongList(List<String> phongIds, String bangGiaId);
  Future<void> xoaBangGiaKhoiTatCaPhong(String bangGiaId, String chuNhaId);
  Future<void> addKhachThueToPhong(String phongId, String nguoiThueId);
  Future<void> removeKhachThueFromPhong(String phongId, String nguoiThueId);
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
  Stream<List<PhongModel>> watchTatCaPhong(String chuNhaId) {
    return _firestore
        .collection('phong')
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

  @override
  Future<void> updateBangGiaChoPhongList(List<String> phongIds, String bangGiaId) async {
    if (phongIds.isEmpty) return;

    final batch = _firestore.batch();
    for (final id in phongIds) {
      final docRef = _firestore.collection('phong').doc(id);
      batch.update(docRef, {'bangGiaId': bangGiaId});
    }

    await batch.commit();
  }

  @override
  Future<void> xoaBangGiaKhoiTatCaPhong(String bangGiaId, String chuNhaId) async {
    final snapshot = await _firestore
        .collection('phong')
        .where('chuNhaId', isEqualTo: chuNhaId)
        .where('bangGiaId', isEqualTo: bangGiaId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'bangGiaId': FieldValue.delete()});
    }

    await batch.commit();
  }

  @override
  Future<void> updateNhaTro(NhaTroModel nhaTro) {
    return _firestore.collection('nha_tro').doc(nhaTro.id).update(nhaTro.toFirestore());
  }

  @override
  Future<void> deleteNhaTroWithPhong(String nhaTroId) async {
    final batch = _firestore.batch();
    
    // 1. Xóa nhà trọ
    batch.delete(_firestore.collection('nha_tro').doc(nhaTroId));
    
    // 2. Tìm và xóa tất cả phòng thuộc nhà trọ này
    final phongSnapshot = await _firestore
        .collection('phong')
        .where('nhaTroId', isEqualTo: nhaTroId)
        .get();
        
    for (final doc in phongSnapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  @override
  Future<void> addKhachThueToPhong(String phongId, String nguoiThueId) {
    return _firestore.collection('phong').doc(phongId).update({
      'khachThue': FieldValue.arrayUnion([nguoiThueId]),
      'trangThai': 1, // Đã thuê
    });
  }

  @override
  Future<void> removeKhachThueFromPhong(String phongId, String nguoiThueId) async {
    final docRef = _firestore.collection('phong').doc(phongId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final currentKhach = List<String>.from(doc.data()?['khachThue'] ?? []);
    currentKhach.remove(nguoiThueId);

    // Update status to available (0) if no more renters
    final status = currentKhach.isEmpty ? 0 : 1;

    await docRef.update({
      'khachThue': FieldValue.arrayRemove([nguoiThueId]),
      'trangThai': status,
    });
  }
}
