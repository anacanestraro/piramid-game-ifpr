import 'package:signals/signals.dart';
import '../../../../core/command/command.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/app_user.dart';
import '../../facade/auth_usecases_facade.dart';

// Dados que as telas entregam aos commands no momento da ação.
typedef LoginInput = ({String email, String password});
typedef SignUpInput = ({
  String email,
  String password,
  String passwordConfirmation,
});

class AuthViewModel {
  final AuthUseCasesFacade _facade;

  AuthViewModel(this._facade) {
    checkAuthCommand = Command0<AppUser?>(_checkAuth);
    loginCommand = Command1<AppUser, LoginInput>(_login);
    loginGoogleCommand = Command0<AppUser>(_loginWithGoogle);
    signUpCommand = Command1<AppUser, SignUpInput>(_signUp);
    logoutCommand = Command0<void>(_logout);
  }

  // Usuário da sessão atual (null = ninguém logado).
  final currentUser = signal<AppUser?>(null);

  late final Computed<bool> isAuthenticated =
      computed(() => currentUser.value != null);

  late final Command0<AppUser?> checkAuthCommand;
  late final Command1<AppUser, LoginInput> loginCommand;
  late final Command0<AppUser> loginGoogleCommand;
  late final Command1<AppUser, SignUpInput> signUpCommand;
  late final Command0<void> logoutCommand;

  Future<Result<AppUser?>> _checkAuth() async {
    final result = await _facade.getCurrentUser();

    result.when(
      onSuccess: (user) => currentUser.value = user,
      onFailure: (_) => currentUser.value = null,
    );

    return result;
  }

  Future<Result<AppUser>> _login(LoginInput input) async {
    final result = await _facade.signIn(
      email: input.email,
      password: input.password,
    );
    _startSession(result);
    return result;
  }

  Future<Result<AppUser>> _loginWithGoogle() async {
    final result = await _facade.signInWithGoogle();
    _startSession(result);
    return result;
  }

  Future<Result<AppUser>> _signUp(SignUpInput input) async {
    final result = await _facade.signUp(
      email: input.email,
      password: input.password,
      passwordConfirmation: input.passwordConfirmation,
    );
    _startSession(result);
    return result;
  }

  Future<Result<void>> _logout() async {
    final result = await _facade.signOut();

    result.when(
      onSuccess: (_) => currentUser.value = null,
      onFailure: (_) {},
    );

    return result;
  }

  // Login, login com Google e cadastro terminam do mesmo jeito:
  // se deu certo, o usuário passa a ser o dono da sessão.
  void _startSession(Result<AppUser> result) {
    result.when(
      onSuccess: (user) => currentUser.value = user,
      onFailure: (_) {},
    );
  }

  void dispose() {
    currentUser.dispose();
    isAuthenticated.dispose();
  }
}