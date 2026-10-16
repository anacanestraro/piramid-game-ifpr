import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_scroll_behavior.dart';
import 'core/theme/app_theme.dart';
import 'features/theme_settings/domain/entities/app_theme_mode.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase precisa estar pronto antes de qualquer service que o utilize.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await InjectionContainer.instance.init();

  runApp(const PiramidGameApp());
}

class PiramidGameApp extends StatelessWidget {
  const PiramidGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeViewModel = InjectionContainer.instance.themeViewModel;

    return SignalBuilder(
      builder: (context) {
        final themeMode = themeViewModel.mode.value;

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'PiramidGame',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode.isDark ? ThemeMode.dark : ThemeMode.light,
          scrollBehavior: AppScrollBehavior(),
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}