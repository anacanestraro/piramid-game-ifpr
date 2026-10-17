import '../../../core/result/result.dart';
import '../domain/entities/app_theme_mode.dart';
import '../domain/usecases/get_theme_mode_usecase.dart';
import '../domain/usecases/toggle_theme_usecase.dart';

// Agrupa os use cases de tema (seção 4.3: alterar tema do aplicativo).
class ThemeUseCasesFacade {
  final GetThemeModeUseCase _getThemeMode;
  final ToggleThemeUseCase _toggleTheme;

  ThemeUseCasesFacade({
    required this._getThemeMode,
    required this._toggleTheme,
  });

  Future<Result<AppThemeMode>> getThemeMode() => _getThemeMode();

  Future<Result<AppThemeMode>> toggleTheme(AppThemeMode currentMode) =>
      _toggleTheme(currentMode);
}