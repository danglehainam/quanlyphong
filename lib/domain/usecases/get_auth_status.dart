import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetAuthStatusUseCase {
  final AuthRepository repository;

  GetAuthStatusUseCase(this.repository);

  Stream<UserEntity?> call() {
    return repository.userStream;
  }
}
