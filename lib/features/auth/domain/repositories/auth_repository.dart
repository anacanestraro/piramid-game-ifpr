import '../../../../core/result/result.dart';
import '../entities/app_user.dart';
abstract class AuthRepository {
  Future<Result<AppUser?>> getCurrentUser();

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