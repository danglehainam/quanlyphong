import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class SaveUserIfNewUseCase {
  final UserRepository repository;

  SaveUserIfNewUseCase(this.repository);

  Future<void> call(UserEntity user) async {
    final exists = await repository.isUserExists(user.uid);
    if (!exists) {
      await repository.saveUser(user);
    }
  }
}
