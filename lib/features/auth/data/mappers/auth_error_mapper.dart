import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/result/result.dart';

// Traduz os códigos de erro do Firebase/Google para mensagens amigáveis.
// Fica na camada de dados: a UI recebe só a Failure com texto pronto.
class AuthErrorMapper {
  AuthErrorMapper._();

  static Failure fromFirebase(FirebaseAuthException e) {
    final message = switch (e.code) {
      'invalid-email' => 'E-mail inválido.',
      'user-disabled' => 'Esta conta foi desativada.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' =>
        'E-mail ou senha incorretos.',
      'email-already-in-use' => 'Já existe uma conta com este e-mail.',
      'weak-password' => 'A senha deve ter pelo menos 6 caracteres.',
      'too-many-requests' =>
        'Muitas tentativas. Aguarde um pouco e tente novamente.',
      'network-request-failed' => 'Sem conexão com a internet.',
      'operation-not-allowed' =>
        'Este método de login não está habilitado no Firebase.',
      'account-exists-with-different-credential' =>
        'Este e-mail já está cadastrado com outro método de login.',
      'popup-closed-by-user' ||
      'cancelled-popup-request' =>
        'Login com Google cancelado.',
      'popup-blocked' =>
        'O navegador bloqueou a janela de login. Permita pop-ups e tente novamente.',
      _ => 'Não foi possível autenticar. Tente novamente.',
    };

    return Failure(message, exception: e);
  }

  static Failure fromGoogle(GoogleSignInException e) {
    final message = switch (e.code) {
      GoogleSignInExceptionCode.canceled => 'Login com Google cancelado.',
      GoogleSignInExceptionCode.clientConfigurationError ||
      GoogleSignInExceptionCode.providerConfigurationError =>
        'Login com Google não está configurado corretamente no Firebase.',
      _ => 'Não foi possível entrar com Google. Tente novamente.',
    };

    return Failure(message, exception: e);
  }
}