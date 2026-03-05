import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

// Import Clean Architecture layers
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/usecases/get_auth_status.dart';
import 'domain/usecases/log_out.dart';
import 'domain/usecases/login_with_google.dart';
import 'domain/usecases/save_user_if_new.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';

// Import BLoC and Screens
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize dependencies
  final AuthRepository authRepository = AuthRepositoryImpl();
  final UserRepository userRepository = UserRepositoryImpl();

  final GetAuthStatusUseCase getAuthStatusUseCase = GetAuthStatusUseCase(authRepository);
  final LoginWithGoogleUseCase loginWithGoogleUseCase = LoginWithGoogleUseCase(authRepository);
  final LogOutUseCase logOutUseCase = LogOutUseCase(authRepository);
  final SaveUserIfNewUseCase saveUserIfNewUseCase = SaveUserIfNewUseCase(userRepository);

  runApp(MyApp(
    getAuthStatusUseCase: getAuthStatusUseCase,
    loginWithGoogleUseCase: loginWithGoogleUseCase,
    logOutUseCase: logOutUseCase,
    saveUserIfNewUseCase: saveUserIfNewUseCase,
  ));
}

class MyApp extends StatelessWidget {
  final GetAuthStatusUseCase getAuthStatusUseCase;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final LogOutUseCase logOutUseCase;
  final SaveUserIfNewUseCase saveUserIfNewUseCase;

  const MyApp({
    super.key,
    required this.getAuthStatusUseCase,
    required this.loginWithGoogleUseCase,
    required this.logOutUseCase,
    required this.saveUserIfNewUseCase,
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return HomeScreen(user: state.user);
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
