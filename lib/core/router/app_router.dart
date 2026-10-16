import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../di/injection_container.dart';
import '../../features/about/presentation/screens/about_screen.dart';
import '../../features/auth/presentation/screens/login/login_screen.dart';
import '../../features/auth/presentation/screens/sign_up/sign_up_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/student/presentation/screens/home/home_screen.dart';
import '../../features/student/presentation/screens/ranking/ranking_screen.dart';
import '../../features/student/presentation/screens/student_detail/student_detail_screen.dart';
import '../../features/student/presentation/screens/student_form/student_form_screen.dart';
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Aba: Inicio
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Aba: Ranking
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.ranking,
                builder: (context, state) => const RankingScreen(),
              ),
            ],
          ),
          // Aba: Cadastro (criar) + editar como sub-rota
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cadastro',
                builder: (context, state) =>
                    const StudentFormScreen(studentId: null),
                routes: [
                  GoRoute(
                    path: 'editar/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return StudentFormScreen(studentId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Aba: Aluno (detalhes)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/aluno',
                builder: (context, state) =>
                    const StudentDetailScreen(studentId: null),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return StudentDetailScreen(studentId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Aba: Sobre
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