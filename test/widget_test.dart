import 'package:flutter_test/flutter_test.dart';
import 'package:chunha/main.dart';
import 'package:chunha/domain/repositories/auth_repository.dart';
import 'package:chunha/domain/repositories/user_repository.dart';
import 'package:chunha/data/repositories/auth_repository_impl.dart';
import 'package:chunha/data/repositories/user_repository_impl.dart';
import 'package:chunha/data/repositories/phong_repository_impl.dart';
import 'package:chunha/domain/usecases/get_auth_status.dart';
import 'package:chunha/domain/usecases/login_with_google.dart';
import 'package:chunha/domain/usecases/log_out.dart';
import 'package:chunha/domain/usecases/save_user_if_new.dart';
import 'package:chunha/domain/usecases/watch_nha_tro_list.dart';
import 'package:chunha/domain/usecases/watch_phong_list.dart';
import 'package:chunha/domain/usecases/them_nha_tro.dart';
void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
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

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      getAuthStatusUseCase: getAuthStatusUseCase,
      loginWithGoogleUseCase: loginWithGoogleUseCase,
      logOutUseCase: logOutUseCase,
      saveUserIfNewUseCase: saveUserIfNewUseCase,
      watchNhaTroList: watchNhaTroList,
      watchPhongList: watchPhongList,
      themNhaTroUseCase: themNhaTroUseCase,
    ));

    // Wait for the app to initialize
    await tester.pumpAndSettle();
  });
}
