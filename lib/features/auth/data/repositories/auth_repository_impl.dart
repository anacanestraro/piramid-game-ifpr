import 'dart:typed_data';
import '../../../../core/result/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/app_user_model.dart';
import '../services/auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/profile_photo_storage_service.dart';
import '../services/session_cache_service.dart';
import '../services/user_remote_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final GoogleAuthService _googleAuthService;
  final UserRemoteService _userRemoteService;
  final SessionCacheService _sessionCache;
  final ProfilePhotoStorageService _photoStorage;

  AuthRepositoryImpl(
    this._authService,
    this._googleAuthService,
    this._userRemoteService,
    this._sessionCache,
    this._photoStorage,
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
  Future<Result<AppUser>> updateProfilePhoto({
    required String uid,
    required Uint8List bytes,
    required String contentType,
  }) async {
    // 1. Envia o arquivo e obtém a URL pública.
    final String photoUrl;
    switch (await _photoStorage.upload(
      uid: uid,
      bytes: bytes,
      contentType: contentType,
    )) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        photoUrl = value;
    }

    // 2. Grava a URL no perfil do Firebase Auth (fonte da verdade).
    final updateResult = await _authService.updatePhotoUrl(photoUrl);

    // 3. Replica no documento "users" e no cache local.
    return _saveProfile(updateResult);
  }

  @override
  Future<Result<void>> signOut() async {
    // Sai da conta Google primeiro. Mesmo que isso falhe,
    // a sessão do Firebase precisa ser encerrada de qualquer forma.
    await _googleAuthService.signOut();
    await _sessionCache.clear();
    return _authService.signOut();
  }

  // Grava o perfil na coleção "users" e no cache local.
  // Usado após autenticar e após trocar a foto.
  //
  // As duas gravações são "melhor esforço": se falharem, a operação
  // continua válida, porque quem garante os dados é o Firebase Auth.
  Future<Result<AppUser>> _saveProfile(Result<AppUserModel> authResult) async {
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