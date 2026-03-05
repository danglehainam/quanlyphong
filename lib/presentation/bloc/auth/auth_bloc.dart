import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../domain/usecases/get_auth_status.dart';
import '../../../../domain/usecases/login_with_google.dart';
import '../../../../domain/usecases/log_out.dart';
import '../../../../domain/usecases/save_user_if_new.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetAuthStatusUseCase _getAuthStatusUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  final LogOutUseCase _logOutUseCase;
  final SaveUserIfNewUseCase _saveUserIfNewUseCase;

  StreamSubscription? _authSubscription;

  AuthBloc({
    required GetAuthStatusUseCase getAuthStatusUseCase,
    required LoginWithGoogleUseCase loginWithGoogleUseCase,
    required LogOutUseCase logOutUseCase,
    required SaveUserIfNewUseCase saveUserIfNewUseCase,
  })  : _getAuthStatusUseCase = getAuthStatusUseCase,
        _loginWithGoogleUseCase = loginWithGoogleUseCase,
        _logOutUseCase = logOutUseCase,
        _saveUserIfNewUseCase = saveUserIfNewUseCase,
        super(AuthInitial()) {
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);

    // Subscribe to auth status stream
    _authSubscription = _getAuthStatusUseCase().listen(
      (user) => add(AuthStatusChanged(user)),
    );
  }

  Future<void> _onAuthStatusChanged(
      AuthStatusChanged event, Emitter<AuthState> emit) async {
    if (event.user != null) {
      // Lưu user vào Firestore nếu là lần đầu đăng nhập
      // Dùng try-catch riêng để lỗi Firestore không block việc đăng nhập
      try {
        await _saveUserIfNewUseCase(event.user!);
      } catch (e) {
        // ignore: avoid_print
        print('Lỗi khi lưu user vào Firestore: $e');
      }
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _loginWithGoogleUseCase();
      if (user == null) {
        emit(const AuthError('Đăng nhập bị hủy hoặc thất bại.'));
        emit(AuthUnauthenticated());
      }
      // If success, getAuthStatus stream will automatically emit AuthAuthenticated
    } catch (e) {
      emit(AuthError('Lỗi đăng nhập: $e'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _logOutUseCase();
      // If success, getAuthStatus stream will automatically emit AuthUnauthenticated
    } catch (e) {
      emit(AuthError('Lỗi đăng xuất: $e'));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
