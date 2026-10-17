import '../../../core/result/result.dart';
import '../domain/entities/app_user.dart';
import '../domain/usecases/get_cached_user_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/sign_in_usecase.dart';
import '../domain/usecases/sign_in_with_google_usecase.dart';
import '../domain/usecases/sign_out_usecase.dart';
import '../domain/usecases/sign_up_usecase.dart';

// Agrupa os use cases de autenticação para que a ViewModel
// dependa de um único objeto, e não de seis casos de uso.
class AuthUseCasesFacade {
  final SignUpUseCase _signUp;
  final SignInUseCase _signIn;
  final SignInWithGoogleUseCase _signInWithGoogle;
  final GetCurrentUserUseCase _getCurrentUser;
  final GetCachedUserUseCase _getCachedUser;
  final SignOutUseCase _signOut;

  AuthUseCasesFacade({
    required this._signUp,
    required this._signIn,
    required this._signInWithGoogle,
    required this._getCurrentUser,
    required this._getCachedUser,
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

  Future<Result<AppUser>> signInWithGoogle() => _signInWithGoogle();

  Future<Result<AppUser?>> getCurrentUser() => _getCurrentUser();

  Future<Result<AppUser?>> getCachedUser() => _getCachedUser();

  Future<Result<void>> signOut() => _signOut();
}