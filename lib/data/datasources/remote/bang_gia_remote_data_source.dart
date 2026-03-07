import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/bang_gia_model.dart';

abstract class BangGiaRemoteDataSource {
  Stream<List<BangGiaModel>> watchBangGiaList(String chuNhaId);
  Future<void> themBangGia(BangGiaModel bangGia);
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
  Future<void> themBangGia(BangGiaModel bangGia) {
    return _firestore.collection('bang_gia').add(bangGia.toFirestore());
  }
}
