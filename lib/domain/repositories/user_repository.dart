import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<bool> isUserExists(String userId);
  Future<void> saveUser(UserEntity user);
}
