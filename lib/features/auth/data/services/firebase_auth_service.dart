import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/result/result.dart';
import '../mappers/auth_error_mapper.dart';
import '../models/app_user_model.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<Result<AppUserModel?>> getCurrentUser() async {
    try {
      // Ao abrir o app, o Firebase ainda está restaurando a sessão salva
      // (principalmente na web), e currentUser pode vir null por engano.
      // O primeiro evento de authStateChanges já traz o estado restaurado.
      final user = await _auth.authStateChanges().first;

      if (user == null) {
        return const Result.success(null);
      }

      return Result.success(AppUserModel.fromFirebaseUser(user));
    } catch (e) {
      return Result.failure(
        Failure('Não foi possível verificar a sessão', exception: e),
      );
    }
  }

  @override
  Future<Result<AppUserModel>> signUp({
    required String email,
    required String password,
  }) {
    return _authenticate(
      () => _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ),
    );
  }

  @override
  Future<Result<AppUserModel>> signIn({
    required String email,
    required String password,
  }) {
    return _authenticate(
      () => _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      ),
    );
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        Failure('Não foi possível encerrar a sessão', exception: e),
      );
    }
  }

  // Executa a chamada ao Firebase e padroniza sucesso/erro,
  // evitando repetir o mesmo try/catch no cadastro e no login.
  Future<Result<AppUserModel>> _authenticate(
    Future<UserCredential> Function() action,
  ) async {
    try {
      final credential = await action();
      final user = credential.user;

      if (user == null) {
        return const Result.failure(
          Failure('Não foi possível obter os dados do usuário'),
        );
      }

      return Result.success(AppUserModel.fromFirebaseUser(user));
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthErrorMapper.fromFirebase(e));
    } catch (e) {
      return Result.failure(
        Failure('Erro inesperado na autenticação', exception: e),
      );
    }
  }
}