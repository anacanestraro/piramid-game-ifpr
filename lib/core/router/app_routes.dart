// Caminhos das rotas centralizados, evitando strings soltas nas telas.
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const signUp = '/criar-conta';

  // --- Pessoas ---
  static const people = '/pessoas';
  static const newPerson = '/pessoas/nova';
  static String personDetail(String id) => '/pessoas/$id';
  static String editPerson(String id) => '/pessoas/$id/editar';

  static const about = '/sobre';

  // Tela inicial após o login.
  // Temporariamente a lista de pessoas; volta a ser o Início no passo 8.
  static const home = people;

  // Rotas acessíveis sem estar autenticado.
  static const publicRoutes = {splash, login, signUp};
}