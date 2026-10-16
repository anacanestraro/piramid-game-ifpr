import '../../../../core/result/result.dart';
import '../models/app_user_model.dart';

// Armazena o perfil do usuário autenticado no banco remoto.
abstract class UserRemoteService {
  Future<Result<void>> saveUser(AppUserModel user);
}