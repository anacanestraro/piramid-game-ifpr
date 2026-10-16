import '../../../../core/result/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';
import 'auth_validator.dart';

// Autenticar usuário com e-mail e senha.
class SignInUseCase {
  final AuthRepository _repository;
  final AuthValidator _validator;

  SignInUseCase(this._repository, {AuthValidator? validator})
      : _validator = validator ?? AuthValidator();

  Future<Result<AppUser>> call({
    required String email,
    required String password,
  }) async {
    final validationError = _validator.validateEmail(email) ??
        _validator.validatePasswordFilled(password);

    if (validationError != null) {
      return Result.failure(validationError);
    }

    return _repository.signIn(email: email, password: password);
  }
}