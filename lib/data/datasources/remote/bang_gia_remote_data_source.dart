import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/bang_gia_model.dart';

abstract class BangGiaRemoteDataSource {
  Stream<List<BangGiaModel>> watchBangGiaList(String chuNhaId);
  Future<String> themBangGia(BangGiaModel bangGia);
  Future<void> xoaBangGia(String id);
  Future<void> updateBangGia(BangGiaModel bangGia);
}

class BangGiaRemoteDataSourceImpl implements BangGiaRemoteDataSource {
  final FirebaseFirestore _firestore;

  BangGiaRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<BangGiaModel>> watchBangGiaList(String chuNhaId) {
    return _firestore
        .collection('bang_gia')
        .where('chuNhaId', isEqualTo: chuNhaId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BangGiaModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<String> themBangGia(BangGiaModel bangGia) async {
    final docRef = await _firestore.collection('bang_gia').add(bangGia.toFirestore());
    return docRef.id;
  }

  @override
  Future<void> xoaBangGia(String id) {
    return _firestore.collection('bang_gia').doc(id).delete();
  }

  @override
  Future<void> updateBangGia(BangGiaModel bangGia) {
    return _firestore.collection('bang_gia').doc(bangGia.id).update(bangGia.toFirestore());
  }
}
