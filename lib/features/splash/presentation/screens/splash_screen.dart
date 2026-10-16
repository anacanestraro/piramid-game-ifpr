import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Tempo mínimo para a Splash não "piscar" quando a verificação é rápida.
  static const _minimumDisplayTime = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    final authViewModel = InjectionContainer.instance.authViewModel;

    // Verifica a sessão e espera o tempo mínimo ao mesmo tempo.
    await Future.wait([
      authViewModel.checkAuthCommand.execute(),
      Future.delayed(_minimumDisplayTime),
    ]);

    if (!mounted) return;

    final destination = authViewModel.isAuthenticated.value
        ? AppRoutes.home
        : AppRoutes.login;

    context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textDim = isDark ? AppColors.darkTextDim : AppColors.lightTextDim;
    final surface2 = isDark ? AppColors.darkSurface2 : AppColors.lightSurface2;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icone do app (trofeu dourado em fundo verde com gradiente)
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

              Text(
                'VERIFICANDO SUA SESSÃO…',
                style: AppTextStyles.jakarta(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textDim,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}