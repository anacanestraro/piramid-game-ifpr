import '../../../../core/result/result.dart';
import '../entities/app_user.dart';

// Contrato usado pelos use cases. Não conhece Firebase,
// Google Sign-In, Firestore nem SharedPreferences.
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

  Future<Result<void>> signOut();
}