import '../../../../core/result/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/app_user_model.dart';
import '../services/auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/session_cache_service.dart';
import '../services/user_remote_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final GoogleAuthService _googleAuthService;
  final UserRemoteService _userRemoteService;
  final SessionCacheService _sessionCache;

  AuthRepositoryImpl(
    this._authService,
    this._googleAuthService,
    this._userRemoteService,
    this._sessionCache,
  );

  @override
  Future<Result<AppUser?>> getCurrentUser() async {
    final result = await _authService.getCurrentUser();

    // Mantém o cache em sintonia com o que o Firebase diz.
    if (result case Success(:final value)) {
      if (value == null) {
        await _sessionCache.clear();
      } else {
        await _sessionCache.saveUser(value);
      }
    }

    return result;
  }

  @override
  Future<Result<AppUser?>> getCachedUser() {
    return _sessionCache.getUser();
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
    return _startSession(result);
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
    return _startSession(result);
  }

  @override
  Future<Result<AppUser>> signInWithGoogle() async {
    final result = await _googleAuthService.signIn();
    return _startSession(result);
  }

  @override
  Future<Result<void>> signOut() async {
    // Sai da conta Google primeiro. Mesmo que isso falhe,
    // a sessão do Firebase precisa ser encerrada de qualquer forma.
    await _googleAuthService.signOut();
    await _sessionCache.clear();
    return _authService.signOut();
  }

  // Após autenticar: grava o perfil na coleção "users" e no cache local.
  //
  // As duas gravações são "melhor esforço": se falharem, o login
  // continua válido, porque quem garante a sessão é o Firebase Auth.
  Future<Result<AppUser>> _startSession(Result<AppUserModel> authResult) async {
    switch (authResult) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        await _userRemoteService.saveUser(value);
        await _sessionCache.saveUser(value);
        return Result.success(value);
    }
  }
}