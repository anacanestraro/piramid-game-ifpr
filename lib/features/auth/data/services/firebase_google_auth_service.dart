import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/result/result.dart';
import '../mappers/auth_error_mapper.dart';
import '../models/app_user_model.dart';
import 'google_auth_service.dart';

// Na web, o próprio Firebase abre o popup do Google.
// No Android, o google_sign_in obtém o token e o Firebase faz o login.
// A diferença de plataforma fica escondida aqui: quem usa só chama signIn().
class FirebaseGoogleAuthService implements GoogleAuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  // Garante que o initialize() do google_sign_in rode uma única vez.
  Future<void>? _initialization;

  FirebaseGoogleAuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  @override
  Future<Result<AppUserModel>> signIn() async {
    try {
      final credential = kIsWeb ? await _signInWeb() : await _signInMobile();
      final user = credential.user;

      if (user == null) {
        return const Result.failure(
          Failure('Não foi possível concluir o login com Google'),
        );
      }

      return Result.success(AppUserModel.fromFirebaseUser(user));
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthErrorMapper.fromFirebase(e));
    } on GoogleSignInException catch (e) {
      return Result.failure(AuthErrorMapper.fromGoogle(e));
    } catch (e) {
      return Result.failure(
        Failure('Erro inesperado no login com Google', exception: e),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    // Na web a sessão do Google não fica presa ao app:
    // o signOut do Firebase já é suficiente.
    if (kIsWeb) return const Result.success(null);

    try {
      await _ensureInitialized();
      // Sem isso, o próximo login entraria direto na mesma conta,
      // sem deixar o usuário escolher outra.
      await _googleSignIn.signOut();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure('Não foi possível sair da conta Google', exception: e),
      );
    }
  }

  Future<UserCredential> _signInWeb() {
    return _auth.signInWithPopup(GoogleAuthProvider());
  }

  Future<UserCredential> _signInMobile() async {
    await _ensureInitialized();

    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _auth.signInWithCredential(credential);
  }

  Future<void> _ensureInitialized() {
    return _initialization ??= _googleSignIn.initialize();
  }
}