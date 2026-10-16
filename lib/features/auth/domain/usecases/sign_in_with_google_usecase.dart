import '../../../../core/result/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

// Autenticar usuário com conta Google.
class SignInWithGoogleUseCase {
  final AuthRepository _repository;

  SignInWithGoogleUseCase(this._repository);

  Future<Result<AppUser>> call() {
    return _repository.signInWithGoogle();
  }
}