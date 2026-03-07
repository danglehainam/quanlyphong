import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<bool> isUserExists(String uid);
  Future<void> saveUser(UserModel user);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  @override
  Future<bool> isUserExists(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    return doc.exists;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _usersCollection.doc(user.uid).set({
      ...user.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
