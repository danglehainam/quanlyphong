import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/nguoi_thue_model.dart';

abstract class NguoiThueRemoteDataSource {
  Stream<List<NguoiThueModel>> watchNguoiThueList(String chuNhaId);
  Future<String> themNguoiThue(NguoiThueModel nguoiThue);
  Future<void> updateNguoiThue(NguoiThueModel nguoiThue);
  Future<void> xoaNguoiThue(String nguoiThueId);
  Future<NguoiThueModel?> getNguoiThueById(String nguoiThueId);
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
  Future<String> themNguoiThue(NguoiThueModel nguoiThue) async {
    final docRef = await _firestore.collection('nguoi_thue').add(nguoiThue.toFirestore());
    return docRef.id;
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

  @override
  Future<NguoiThueModel?> getNguoiThueById(String nguoiThueId) async {
    final doc = await _firestore.collection('nguoi_thue').doc(nguoiThueId).get();
    if (!doc.exists) return null;
    return NguoiThueModel.fromFirestore(doc);
  }
}
