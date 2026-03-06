import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'core/constants/app_colors.dart';

// Import Clean Architecture layers
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/usecases/get_auth_status.dart';
import 'domain/usecases/log_out.dart';
import 'domain/usecases/login_with_google.dart';
import 'domain/usecases/save_user_if_new.dart';
import 'domain/usecases/watch_nha_tro_list.dart';
import 'domain/usecases/watch_phong_list.dart';
import 'domain/usecases/them_nha_tro.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'data/repositories/phong_repository_impl.dart';

// Import BLoC and Screens
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize dependencies
  final AuthRepository authRepository = AuthRepositoryImpl();
  final UserRepository userRepository = UserRepositoryImpl();
  final phongRepository = PhongRepositoryImpl();

  final GetAuthStatusUseCase getAuthStatusUseCase = GetAuthStatusUseCase(authRepository);
  final LoginWithGoogleUseCase loginWithGoogleUseCase = LoginWithGoogleUseCase(authRepository);
  final LogOutUseCase logOutUseCase = LogOutUseCase(authRepository);
  final SaveUserIfNewUseCase saveUserIfNewUseCase = SaveUserIfNewUseCase(userRepository);
  final watchNhaTroList = WatchNhaTroListUseCase(phongRepository);
  final watchPhongList = WatchPhongListUseCase(phongRepository);
  final themNhaTroUseCase = ThemNhaTroUseCase(phongRepository);

  runApp(MyApp(
    getAuthStatusUseCase: getAuthStatusUseCase,
    loginWithGoogleUseCase: loginWithGoogleUseCase,
    logOutUseCase: logOutUseCase,
    saveUserIfNewUseCase: saveUserIfNewUseCase,
    watchNhaTroList: watchNhaTroList,
    watchPhongList: watchPhongList,
    themNhaTroUseCase: themNhaTroUseCase,
  ));
}

class MyApp extends StatelessWidget {
  final GetAuthStatusUseCase getAuthStatusUseCase;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final LogOutUseCase logOutUseCase;
  final SaveUserIfNewUseCase saveUserIfNewUseCase;
  final WatchNhaTroListUseCase watchNhaTroList;
  final WatchPhongListUseCase watchPhongList;
  final ThemNhaTroUseCase themNhaTroUseCase;

  const MyApp({
    super.key,
    required this.getAuthStatusUseCase,
    required this.loginWithGoogleUseCase,
    required this.logOutUseCase,
    required this.saveUserIfNewUseCase,
    required this.watchNhaTroList,
    required this.watchPhongList,
    required this.themNhaTroUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(
        getAuthStatusUseCase: getAuthStatusUseCase,
        loginWithGoogleUseCase: loginWithGoogleUseCase,
        logOutUseCase: logOutUseCase,
        saveUserIfNewUseCase: saveUserIfNewUseCase,
      ),
      child: MaterialApp(
        title: 'Chủ Nhà',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return MainScreen(
                user: state.user,
                watchNhaTroList: watchNhaTroList,
                watchPhongList: watchPhongList,
                themNhaTroUseCase: themNhaTroUseCase,
              );
            }
            if (state is AuthLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            // Defaults (AuthInitial, AuthUnauthenticated, AuthError)
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
