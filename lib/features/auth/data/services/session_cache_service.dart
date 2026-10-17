import '../../../../core/result/result.dart';
import '../models/app_user_model.dart';

// Cache local do usuário autenticado (seção 3.3 da especificação).
// Serve só para agilizar a abertura do app: quem decide se a sessão
// é válida continua sendo o Firebase Authentication.
abstract class SessionCacheService {
  Future<Result<AppUserModel?>> getUser();
  Future<Result<void>> saveUser(AppUserModel user);
  Future<Result<void>> clear();
}