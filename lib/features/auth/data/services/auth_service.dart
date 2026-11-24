import '../../../../core/result/result.dart';
import '../models/app_user_model.dart';

// Comunicação com o provedor de autenticação:
// sessão, e-mail/senha e dados do perfil da conta.
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

  // Atualiza a foto do perfil da conta logada e retorna o usuário atualizado.
  Future<Result<AppUserModel>> updatePhotoUrl(String photoUrl);

  Future<Result<void>> signOut();
}