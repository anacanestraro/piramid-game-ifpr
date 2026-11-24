import 'dart:typed_data';
import '../../../../core/result/result.dart';
import '../entities/app_user.dart';

// Contrato usado pelos use cases. Não conhece Firebase,
// Google Sign-In, Firestore, Storage nem SharedPreferences.
abstract class AuthRepository {
  // Retorna o usuário com sessão válida, ou null se não houver.
  Future<Result<AppUser?>> getCurrentUser();

  // Último usuário salvo localmente. Não garante sessão válida.
  Future<Result<AppUser?>> getCachedUser();

  Future<Result<AppUser>> signUp({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> signInWithGoogle();

  // Envia a nova foto e atualiza o perfil. Retorna o usuário atualizado.
  Future<Result<AppUser>> updateProfilePhoto({
    required String uid,
    required Uint8List bytes,
    required String contentType,
  });

  Future<Result<void>> signOut();
}