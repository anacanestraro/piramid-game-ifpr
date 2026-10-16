import '../../../core/result/result.dart';
import '../domain/entities/app_user.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/sign_in_usecase.dart';
import '../domain/usecases/sign_in_with_google_usecase.dart';
import '../domain/usecases/sign_out_usecase.dart';
import '../domain/usecases/sign_up_usecase.dart';

// Agrupa os use cases de autenticação para que a ViewModel
// dependa de um único objeto, e não de cinco casos de uso.
class AuthUseCasesFacade {
  final SignUpUseCase _signUp;
  final SignInUseCase _signIn;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final GetCurrentUserUseCase _getCurrentUser;
  final SignOutUseCase _signOut;

  // Dart 3.12: parâmetro nomeado privado. Quem chama usa "signUp:",
  // e o valor vai direto para o campo "_signUp".
  AuthUseCasesFacade({
    required this._signUp,
    required this._signIn,
    required this._signInWithGoogle,
    required this._getCurrentUser,
    required this._signOut,
  });

  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _signUp(
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }

  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) {
    return _signIn(email: email, password: password);
  }

  Future<Result<AppUser>> signInWithGoogle() {
    return _signInWithGoogle();
  }

  Future<Result<AppUser?>> getCurrentUser() {
    return _getCurrentUser();
  }

  Future<Result<void>> signOut() {
    return _signOut();
  }
}