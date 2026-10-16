import '../../../../core/result/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';
import 'auth_validator.dart';

// Cadastrar usuário com e-mail e senha.
class SignUpUseCase {
  final AuthRepository _repository;
  final AuthValidator _validator;

  SignUpUseCase(this._repository, {AuthValidator? validator})
      : _validator = validator ?? AuthValidator();

  Future<Result<AppUser>> call({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final validationError = _validator.validateEmail(email) ??
        _validator.validateNewPassword(password) ??
        _validator.validatePasswordConfirmation(password, passwordConfirmation);

    if (validationError != null) {
      return Result.failure(validationError);
    }

    return _repository.signUp(email: email, password: password);
  }
}