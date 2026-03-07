import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/user_remote_data_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<bool> isUserExists(String uid) async {
    return remoteDataSource.isUserExists(uid);
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    final userModel = UserModel.fromEntity(user);
    
    await remoteDataSource.saveUser(userModel);
  }
}
