// Caminhos das rotas centralizados, evitando strings soltas nas telas.
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const signUp = '/criar-conta';

  // --- Abas ---
  static const home = '/inicio';
  static const ranking = '/ranking';
  static const people = '/pessoas';
  static const about = '/sobre';

  // --- Pessoas ---
  static const newPerson = '/pessoas/nova';
  static String personDetail(String id) => '/pessoas/$id';
  static String editPerson(String id) => '/pessoas/$id/editar';

  // --- Avaliações ---
  static String evaluatePerson(String personId) => '/pessoas/$personId/avaliar';

  // Rotas acessíveis sem estar autenticado.
  static const publicRoutes = {splash, login, signUp};
}