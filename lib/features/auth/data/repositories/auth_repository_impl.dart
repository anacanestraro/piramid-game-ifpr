import '../../../../core/result/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/app_user_model.dart';
import '../services/auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/user_remote_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final GoogleAuthService _googleAuthService;
  final UserRemoteService _userRemoteService;

  AuthRepositoryImpl(
    this._authService,
    this._googleAuthService,
    this._userRemoteService,
  );

  @override
  Future<Result<AppUser?>> getCurrentUser() {
    return _authService.getCurrentUser();
  }

  @override
  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
  }) async {
    final result = await _authService.signUp(
      email: email,
      password: password,
    );
    return _saveProfile(result);
  }

  @override
  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _authService.signIn(
      email: email,
      password: password,
    );
    return _saveProfile(result);
  }

  @override
  Future<Result<AppUser>> signInWithGoogle() async {
    final result = await _googleAuthService.signIn();
    return _saveProfile(result);
  }

  @override
  Future<Result<void>> signOut() async {
    // Sai da conta Google primeiro. Mesmo que isso falhe,
    // a sessão do Firebase precisa ser encerrada de qualquer forma.
    await _googleAuthService.signOut();
    return _authService.signOut();
  }

  // Após autenticar, grava/atualiza o perfil na coleção "users".
  //
  // A gravação é "melhor esforço": se o Firestore falhar aqui, o login
  // continua válido, porque quem garante a sessão é o Firebase Auth.
  // Como o perfil é regravado a cada login (merge), ele se corrige
  // sozinho na próxima vez.
  Future<Result<AppUser>> _saveProfile(Result<AppUserModel> authResult) async {
    switch (authResult) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        await _userRemoteService.saveUser(value);
        return Result.success(value);
    }
  }
}