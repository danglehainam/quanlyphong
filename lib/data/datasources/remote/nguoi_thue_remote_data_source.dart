import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/nguoi_thue_model.dart';

abstract class NguoiThueRemoteDataSource {
  Stream<List<NguoiThueModel>> watchNguoiThueList(String chuNhaId);
  Future<void> themNguoiThue(NguoiThueModel nguoiThue);
  Future<void> updateNguoiThue(NguoiThueModel nguoiThue);
  Future<void> xoaNguoiThue(String nguoiThueId);
}

class NguoiThueRemoteDataSourceImpl implements NguoiThueRemoteDataSource {
  final FirebaseFirestore _firestore;

  NguoiThueRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<NguoiThueModel>> watchNguoiThueList(String chuNhaId) {
    return _firestore
        .collection('nguoi_thue')
        .where('chuNhaId', isEqualTo: chuNhaId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NguoiThueModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> themNguoiThue(NguoiThueModel nguoiThue) {
    return _firestore.collection('nguoi_thue').add(nguoiThue.toFirestore());
  }

  @override
  Future<void> updateNguoiThue(NguoiThueModel nguoiThue) {
    return _firestore
        .collection('nguoi_thue')
        .doc(nguoiThue.id)
        .update(nguoiThue.toFirestore());
  }

  @override
  Future<void> xoaNguoiThue(String nguoiThueId) {
    return _firestore.collection('nguoi_thue').doc(nguoiThueId).delete();
  }
}
