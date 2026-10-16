import '../../../../core/result/result.dart';
import '../models/app_user_model.dart';

// Comunicação com o provedor de autenticação por e-mail e senha.
abstract class AuthService {
  Future<Result<AppUserModel?>> getCurrentUser();

  Future<Result<AppUserModel>> signUp({
    required String email,
    required String password,
  });

  Future<Result<AppUserModel>> signIn({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();
}