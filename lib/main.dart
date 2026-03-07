import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'core/constants/app_colors.dart';
// Import BLoC and Screens
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/bloc/phong/phong_bloc.dart';
import 'presentation/bloc/phong/phong_event.dart';

import 'core/di/dependency_injection.dart' as dependency_injection;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize dependencies with GetIt
  await dependency_injection.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => dependency_injection.serviceLocator<AuthBloc>(),
      child: MaterialApp(
        title: 'Chủ Nhà',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return BlocProvider(
                create: (context) =>
                    dependency_injection.serviceLocator<PhongBloc>()
                      ..add(PhongStarted(state.user.uid)),
                child: MainScreen(user: state.user),
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

