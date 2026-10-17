import 'package:signals/signals.dart';
import '../../../../core/command/command.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../../facade/theme_usecases_facade.dart';

class ThemeViewModel {
  final ThemeUseCasesFacade _facade;

  ThemeViewModel(this._facade) {
    loadThemeCommand = Command0<AppThemeMode>(_load);
    toggleThemeCommand = Command0<AppThemeMode>(_toggle);

    // Lê o tema salvo assim que a ViewModel é criada.
    loadThemeCommand.execute();
  }

  late final Command0<AppThemeMode> loadThemeCommand;
  late final Command0<AppThemeMode> toggleThemeCommand;

  final mode = signal<AppThemeMode>(AppThemeMode.light);

  // Atalho usado pelo botão de tema.
  Future<void> toggle() => toggleThemeCommand.execute();

  Future<Result<AppThemeMode>> _load() async {
    final result = await _facade.getThemeMode();
    result.when(
      onSuccess: (loaded) => mode.value = loaded,
      // Sem preferência salva ou erro de leitura: mantém o tema claro.
      onFailure: (_) {},
    );
    return result;
  }

  Future<Result<AppThemeMode>> _toggle() async {
    final result = await _facade.toggleTheme(mode.value);
    result.when(
      onSuccess: (newMode) => mode.value = newMode,
      onFailure: (_) {},
    );
    return result;
  }

  void dispose() {
    mode.dispose();
  }
}