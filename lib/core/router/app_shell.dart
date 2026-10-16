import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../di/injection_container.dart';
import '../theme/app_colors.dart';
import '../ui/app_feedback.dart';
import '../../features/theme_settings/domain/entities/app_theme_mode.dart';
import 'app_routes.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  void _onTap(int index) {
    if (index == 1) {
      InjectionContainer.instance.rankingViewModel.refresh();
    }

    if (index == 2) {
      InjectionContainer.instance.studentFormViewModel.reset();
    }

    if (index == 3) {
      final currentStudent =
          InjectionContainer.instance.studentDetailViewModel.student.value;
      if (currentStudent != null) {
        InjectionContainer.instance.studentDetailViewModel
            .loadStudent(currentStudent.id);
      }
    }

    navigationShell.goBranch(
      index,
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
              icon: Icon(Icons.home_rounded), label: 'Início'),
          NavigationDestination(
              icon: Icon(Icons.leaderboard_rounded), label: 'Ranking'),
          NavigationDestination(
              icon: Icon(Icons.add_circle_rounded), label: 'Cadastrar'),
          NavigationDestination(
              icon: Icon(Icons.account_circle_rounded), label: 'Aluno'),
          NavigationDestination(
              icon: Icon(Icons.info_rounded), label: 'Sobre'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você precisará entrar novamente para usar o app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

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