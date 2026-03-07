import 'package:get_it/get_it.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/phong_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/phong_repository_impl.dart';
import '../../domain/usecases/get_auth_status.dart';
import '../../domain/usecases/log_out.dart';
import '../../domain/usecases/login_with_google.dart';
import '../../domain/usecases/save_user_if_new.dart';
import '../../domain/usecases/watch_nha_tro_list.dart';
import '../../domain/usecases/watch_phong_list.dart';
import '../../domain/usecases/them_nha_tro.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> init() async {
  // 1. Repositories
  serviceLocator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  serviceLocator.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());
  serviceLocator.registerLazySingleton<PhongRepository>(() => PhongRepositoryImpl());

  // 2. Use Cases
  serviceLocator.registerLazySingleton(() => GetAuthStatusUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => LoginWithGoogleUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => LogOutUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => SaveUserIfNewUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => WatchNhaTroListUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => WatchPhongListUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => ThemNhaTroUseCase(serviceLocator()));

  // 3. Blocs
  serviceLocator.registerFactory(() => AuthBloc(
        getAuthStatusUseCase: serviceLocator(),
        loginWithGoogleUseCase: serviceLocator(),
        logOutUseCase: serviceLocator(),
        saveUserIfNewUseCase: serviceLocator(),
      ));
}