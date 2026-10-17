import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../di/injection_container.dart';
import '../../features/about/presentation/screens/about_screen.dart';
import '../../features/auth/presentation/screens/login/login_screen.dart';
import '../../features/auth/presentation/screens/sign_up/sign_up_screen.dart';
import '../../features/evaluation/presentation/screens/evaluation_form/evaluation_form_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/person/presentation/screens/people_list/people_list_screen.dart';
import '../../features/person/presentation/screens/person_detail/person_detail_screen.dart';
import '../../features/person/presentation/screens/person_form/person_form_screen.dart';
import '../../features/ranking/presentation/screens/ranking/ranking_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'app_routes.dart';
import 'app_shell.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: _guard,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),

      // Telas em tela cheia (por cima das abas).
      // Declaradas antes do shell para "/pessoas/nova" não ser
      // interpretado como "/pessoas/:id".
      GoRoute(
        path: AppRoutes.newPerson,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PersonFormScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.people}/:id/editar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PersonFormScreen(personId: id);
        },
      ),
      GoRoute(
        path: '${AppRoutes.people}/:id/avaliar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EvaluationFormScreen(personId: id);
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Aba 0: Início
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Aba 1: Ranking (pessoal e global)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.ranking,
                builder: (context, state) => const RankingScreen(),
              ),
            ],
          ),
          // Aba 2: Pessoas (lista + detalhes)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.people,
                builder: (context, state) => const PeopleListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return PersonDetailScreen(personId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Aba 3: Sobre
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.about,
                builder: (context, state) => const AboutScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // Executado antes de cada navegação.
  // Retornar null = segue para a rota pedida; retornar um caminho = desvia.
  static String? _guard(BuildContext context, GoRouterState state) {
    final location = state.matchedLocation;
    final isPublic = AppRoutes.publicRoutes.contains(location);
    final isAuthenticated =
        InjectionContainer.instance.authViewModel.isAuthenticated.value;

    // Sem sessão tentando acessar área protegida -> login.
    if (!isAuthenticated && !isPublic) {
      return AppRoutes.login;
    }

    // Já logado tentando abrir login/criar conta -> início.
    final isAuthScreen =
        location == AppRoutes.login || location == AppRoutes.signUp;
    if (isAuthenticated && isAuthScreen) {
      return AppRoutes.home;
    }

    return null;
  }
}