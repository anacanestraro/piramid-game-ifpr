import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  // Rota a retomar após verificar a sessão (ex.: a tela onde foi dado F5).
  final String? redirectTo;

  const SplashScreen({super.key, this.redirectTo});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Primeira abertura: dá tempo de ver a apresentação.
  static const _firstVisitDisplayTime = Duration(milliseconds: 1500);
  // Usuário já conhecido (cache): abertura mais rápida.
  static const _returningDisplayTime = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    final authViewModel = InjectionContainer.instance.authViewModel;

    // 1) Cache local: só para personalizar a Splash.
    await authViewModel.loadCachedUserCommand.execute();
    final isReturning = authViewModel.cachedUser.value != null;

    // 2) Firebase: decide de verdade se a sessão é válida.
    await Future.wait([
      authViewModel.checkAuthCommand.execute(),
      Future.delayed(
        isReturning ? _returningDisplayTime : _firstVisitDisplayTime,
      ),
    ]);

    if (!mounted) return;

    if (!authViewModel.isAuthenticated.value) {
      context.go(AppRoutes.login);
      return;
    }

    final redirect = widget.redirectTo;
    context.go(
      AppRoutes.isSafeRedirect(redirect) ? redirect! : AppRoutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textDim = isDark ? AppColors.darkTextDim : AppColors.lightTextDim;
    final surface2 = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;
    final authViewModel = InjectionContainer.instance.authViewModel;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone do app (troféu dourado em fundo verde com gradiente)
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(38),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.green, AppColors.greenDeep],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withValues(alpha: .4),
                      blurRadius: 44,
                      offset: const Offset(0, 22),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 70,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 30),

              Text('PiramidGame', style: AppTextStyles.splashTitle),
              const SizedBox(height: 8),

              Text(
                'Ranking de Popularidade',
                style: AppTextStyles.jakarta(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                'IFPR · Campus Paranaguá',
                style: AppTextStyles.jakarta(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: textDim,
                ),
              ),
              const SizedBox(height: 44),

              // Barra de loading
              Container(
                width: 168,
                height: 5,
                decoration: BoxDecoration(
                  color: surface2,
                  borderRadius: BorderRadius.circular(99),
                ),
                clipBehavior: Clip.hardEdge,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.4,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.green, AppColors.gold],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              SignalBuilder(
                builder: (context) {
                  final cached = authViewModel.cachedUser.value;

                  return Text(
                    cached == null
                        ? 'VERIFICANDO SUA SESSÃO…'
                        : 'BEM-VINDO DE VOLTA, ${cached.name.toUpperCase()}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.jakarta(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textDim,
                      letterSpacing: 1.5,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}