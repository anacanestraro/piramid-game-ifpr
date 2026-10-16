import '../../../../core/result/result.dart';

// Regras de validação das credenciais.
// Retorna null se válido, ou uma Failure descrevendo o problema
// (mesmo padrão do StudentValidator).
class AuthValidator {
  // Mínimo exigido pelo próprio Firebase Authentication.
  static const minPasswordLength = 6;

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  Failure? validateEmail(String email) {
    final trimmed = email.trim();

    if (trimmed.isEmpty) {
      return const Failure('Informe o e-mail.');
    }

    if (!_emailPattern.hasMatch(trimmed)) {
      return const Failure('E-mail inválido.');
    }

    return null;
  }

  // Usada no login: só verifica se foi preenchida.
  Failure? validatePasswordFilled(String password) {
    if (password.isEmpty) {
      return const Failure('Informe a senha.');
    }
    return null;
  }

  // Usada no cadastro: aplica o tamanho mínimo.
  Failure? validateNewPassword(String password) {
    if (password.length < minPasswordLength) {
      return const Failure(
        'A senha deve ter pelo menos $minPasswordLength caracteres.',
      );
    }
    return null;
  }

  Failure? validatePasswordConfirmation(String password, String confirmation) {
    if (password != confirmation) {
      return const Failure('As senhas não conferem.');
    }
    return null;
  }
}