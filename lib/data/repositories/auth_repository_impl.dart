import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Stream<UserEntity?> get userStream {
    return remoteDataSource.userStream.map((userModel) => userModel?.toEntity());
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final userModel = await remoteDataSource.signInWithGoogle();
      return userModel?.toEntity();
    } catch (e) {
      // ignore: avoid_print
      print("Error in repository signing in with Google: $e");
      return null;
    }
  }

  @override
  Future<void> logOut() async {
    await remoteDataSource.logOut();
  }
}
