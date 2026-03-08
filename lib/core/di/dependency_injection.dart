import 'package:get_it/get_it.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/phong_repository.dart';
import '../../domain/repositories/bang_gia_repository.dart';

import '../../data/datasources/remote/auth_remote_data_source.dart';
import '../../data/datasources/remote/user_remote_data_source.dart';
import '../../data/datasources/remote/phong_remote_data_source.dart';
import '../../data/datasources/remote/bang_gia_remote_data_source.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/phong_repository_impl.dart';
import '../../data/repositories/bang_gia_repository_impl.dart';

import '../../domain/usecases/get_auth_status.dart';
import '../../domain/usecases/log_out.dart';
import '../../domain/usecases/login_with_google.dart';
import '../../domain/usecases/save_user_if_new.dart';
import '../../domain/usecases/watch_nha_tro_list.dart';
import '../../domain/usecases/watch_phong_list.dart';
import '../../domain/usecases/them_nha_tro.dart';
import '../../domain/usecases/watch_bang_gia_list.dart';
import '../../domain/usecases/them_bang_gia.dart';
import '../../domain/usecases/watch_tat_ca_phong.dart';
import '../../domain/usecases/update_bang_gia_cho_phong_list.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/phong/phong_bloc.dart';
import '../../presentation/bloc/bang_gia/bang_gia_bloc.dart';
import '../../presentation/bloc/ap_dung_bang_gia/ap_dung_bang_gia_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final serviceLocator = GetIt.instance;

Future<void> init() async {
  // 1. Data Sources
  serviceLocator.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
  serviceLocator.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSourceImpl());
  serviceLocator.registerLazySingleton<PhongRemoteDataSource>(() => PhongRemoteDataSourceImpl());
  serviceLocator.registerLazySingleton<BangGiaRemoteDataSource>(() => BangGiaRemoteDataSourceImpl(FirebaseFirestore.instance));

  // 2. Repositories
  serviceLocator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: serviceLocator()));
  serviceLocator.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(remoteDataSource: serviceLocator()));
  serviceLocator.registerLazySingleton<PhongRepository>(() => PhongRepositoryImpl(remoteDataSource: serviceLocator()));
  serviceLocator.registerLazySingleton<BangGiaRepository>(() => BangGiaRepositoryImpl(serviceLocator()));

  // 2. Use Cases
  serviceLocator.registerLazySingleton(() => GetAuthStatusUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => LoginWithGoogleUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => LogOutUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => SaveUserIfNewUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => WatchNhaTroListUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => WatchPhongListUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => ThemNhaTroUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => WatchBangGiaListUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => ThemBangGiaUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => WatchTatCaPhongUseCase(serviceLocator()));
  serviceLocator.registerLazySingleton(() => UpdateBangGiaChoPhongListUseCase(serviceLocator()));

  // 3. Blocs
  serviceLocator.registerFactory(() => AuthBloc(
        getAuthStatusUseCase: serviceLocator(),
        loginWithGoogleUseCase: serviceLocator(),
        logOutUseCase: serviceLocator(),
        saveUserIfNewUseCase: serviceLocator(),
      ));

  serviceLocator.registerFactory(() => PhongBloc(
        watchNhaTroList: serviceLocator(),
        watchPhongList: serviceLocator(),
        themNhaTroUseCase: serviceLocator(),
      ));

  serviceLocator.registerFactory(() => BangGiaBloc(
        watchBangGiaListUseCase: serviceLocator(),
        themBangGiaUseCase: serviceLocator(),
      ));

  serviceLocator.registerFactory(() => ApDungBangGiaBloc(
        watchNhaTroList: serviceLocator(),
        watchTatCaPhong: serviceLocator(),
        updateBangGiaChoPhongList: serviceLocator(),
      ));
}