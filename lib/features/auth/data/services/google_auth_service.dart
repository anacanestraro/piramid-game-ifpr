import '../../../../core/result/result.dart';
import '../models/app_user_model.dart';

// Autenticação com conta Google integrada ao Firebase Authentication.
abstract class GoogleAuthService {
  Future<Result<AppUserModel>> signIn();
  Future<Result<void>> signOut();
}