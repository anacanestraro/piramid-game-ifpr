// Caminhos das rotas centralizados, evitando strings soltas nas telas.
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const signUp = '/criar-conta';

  static const home = '/inicio';
  static const ranking = '/ranking';
  static const about = '/sobre';

  // Rotas acessíveis sem estar autenticado.
  static const publicRoutes = {splash, login, signUp};
}