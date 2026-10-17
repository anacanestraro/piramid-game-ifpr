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
    loadCachedUserCommand = Command0<AppUser?>(_loadCachedUser);
    checkAuthCommand = Command0<AppUser?>(_checkAuth);
    loginCommand = Command1<AppUser, LoginInput>(_login);
    loginGoogleCommand = Command0<AppUser>(_loginWithGoogle);
    signUpCommand = Command1<AppUser, SignUpInput>(_signUp);
    logoutCommand = Command0<void>(_logout);
  }

  // Usuário da sessão atual, confirmado pelo Firebase (null = ninguém).
  final currentUser = signal<AppUser?>(null);

  // Último usuário salvo no dispositivo. Só para exibição na Splash.
  final cachedUser = signal<AppUser?>(null);

  // false até o Firebase responder se existe sessão. Enquanto for false,
  // o router não pode concluir que o usuário está deslogado.
  final sessionChecked = signal(false);

  late final Computed<bool> isAuthenticated =
      computed(() => currentUser.value != null);

  late final Command0<AppUser?> loadCachedUserCommand;
  late final Command0<AppUser?> checkAuthCommand;
  late final Command1<AppUser, LoginInput> loginCommand;
  late final Command0<AppUser> loginGoogleCommand;
  late final Command1<AppUser, SignUpInput> signUpCommand;
  late final Command0<void> logoutCommand;

  Future<Result<AppUser?>> _loadCachedUser() async {
    final result = await _facade.getCachedUser();
    result.when(
      onSuccess: (user) => cachedUser.value = user,
      onFailure: (_) => cachedUser.value = null,
    );
    return result;
  }

  Future<Result<AppUser?>> _checkAuth() async {
    final result = await _facade.getCurrentUser();

    batch(() {
      result.when(
        onSuccess: (user) => currentUser.value = user,
        onFailure: (_) => currentUser.value = null,
      );
      sessionChecked.value = true;
    });

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
      onSuccess: (_) => batch(() {
        currentUser.value = null;
        cachedUser.value = null;
      }),
      onFailure: (_) {},
    );

    return result;
  }

  // Login, login com Google e cadastro terminam do mesmo jeito:
  // se deu certo, o usuário passa a ser o dono da sessão.
  void _startSession(Result<AppUser> result) {
    result.when(
      onSuccess: (user) => batch(() {
        currentUser.value = user;
        cachedUser.value = user;
        sessionChecked.value = true;
      }),
      onFailure: (_) {},
    );
  }

  void dispose() {
    currentUser.dispose();
    cachedUser.dispose();
    sessionChecked.dispose();
    isAuthenticated.dispose();
  }
}