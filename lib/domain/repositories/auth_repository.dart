import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signInWithGoogle();
  Future<void> logOut();
  Stream<UserEntity?> get userStream;
}
