import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../di/injection_container.dart';
import '../theme/app_colors.dart';
import '../ui/app_feedback.dart';
import '../ui/confirm_dialog.dart';
import '../../features/theme_settings/domain/entities/app_theme_mode.dart';
import 'app_routes.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  static const _peopleTab = 0;

  void _onTap(int index) {
    if (index == _peopleTab) {
      InjectionContainer.instance.peopleListViewModel.refresh();
    }

    navigationShell.goBranch(
      index,
      // Tocar de novo na aba atual volta para o início dela.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          const Positioned(
            top: 8,
            right: 16,
            child: SafeArea(child: _TopActions()),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.groups_rounded),
            label: 'Pessoas',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_rounded),
            label: 'Sobre',
          ),
        ],
      ),
    );
  }
}

// Ações fixas no topo: alternar tema e sair.
class _TopActions extends StatelessWidget {
  const _TopActions();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ThemeToggleButton(),
        SizedBox(width: 8),
        _LogoutButton(),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onPressed;

  const _RoundIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: color),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    final viewModel = InjectionContainer.instance.themeViewModel;

    return SignalBuilder(
      builder: (context) {
        final isDark = viewModel.mode.value.isDark;

        return _RoundIconButton(
          icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          color: AppColors.green,
          tooltip: isDark ? 'Tema claro' : 'Tema escuro',
          onPressed: viewModel.toggle,
        );
      },
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  Future<void> _confirmAndLogout(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Sair da conta?',
      message: 'Você precisará entrar novamente para usar o app.',
      confirmLabel: 'Sair',
      isDestructive: true,
    );

    if (!confirmed || !context.mounted) return;

    final viewModel = InjectionContainer.instance.authViewModel;
    await viewModel.logoutCommand.execute();

    if (!context.mounted) return;

    final state = viewModel.logoutCommand.state.value;
    if (state.isSuccess) {
      context.go(AppRoutes.login);
    } else if (state.isError) {
      AppFeedback.showError(context, state.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = InjectionContainer.instance.authViewModel;

    return SignalBuilder(
      builder: (context) {
        final isLoggingOut = viewModel.logoutCommand.state.value.isRunning;

        return _RoundIconButton(
          icon: Icons.logout_rounded,
          color: AppColors.red,
          tooltip: 'Sair',
          onPressed: isLoggingOut ? null : () => _confirmAndLogout(context),
        );
      },
    );
  }
}