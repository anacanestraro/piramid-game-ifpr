import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/ui/primary_button.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../ranking/domain/entities/ranking_entry.dart';
import '../../../evaluation/domain/entities/popularity_tier.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _container = InjectionContainer.instance;

  @override
  void initState() {
    super.initState();
    _container.rankingViewModel.refresh();
    _container.peopleListViewModel.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final rankingViewModel = _container.rankingViewModel;
    final peopleViewModel = _container.peopleListViewModel;
    final authViewModel = _container.authViewModel;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          child: SignalBuilder(
            builder: (context) {
              final userName = authViewModel.currentUser.value?.name ?? '';
              final leader = rankingViewModel.globalLeader.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  const _Logo(),
                  const SizedBox(height: 16),
                  Text(
                    'PiramidGame',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sora(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  Text(
                    userName.isEmpty ? 'Bem-vindo!' : 'Olá, $userName!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.jakarta(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '${peopleViewModel.people.value.length}',
                          label: 'Pessoas na disputa',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: '${rankingViewModel.myEvaluationCount.value}',
                          label: 'Avaliadas por você',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _LeaderCard(leader: leader),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Ver ranking',
                    icon: Icons.leaderboard_rounded,
                    onPressed: () => context.go(AppRoutes.ranking),
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    label: 'Avaliar pessoas',
                    icon: Icons.star_rounded,
                    color: AppColors.red,
                    onPressed: () => context.go(AppRoutes.people),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.green, AppColors.greenDeep],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withValues(alpha: .4),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: const Icon(
          Icons.emoji_events_rounded,
          size: 48,
          color: AppColors.gold,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.cardNumber),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.jakarta(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: .6),
            ),
          ),
        ],
      ),
    );
  }
}

// Líder do ranking global.
class _LeaderCard extends StatelessWidget {
  final RankingEntry? leader;

  const _LeaderCard({required this.leader});

  @override
  Widget build(BuildContext context) {
    final current = leader;

    return Container(
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.green, AppColors.greenDeep],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -10,
            bottom: -18,
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 110,
              color: Colors.white.withValues(alpha: .13),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LÍDER DO RANKING GLOBAL',
                style: AppTextStyles.jakarta(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .5,
                  color: Colors.white.withValues(alpha: .85),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                current == null ? 'Ninguém ainda' : current.person.name,
                style: AppTextStyles.sora(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                current == null
                    ? 'Avalie alguém para iniciar a disputa'
                    : '${AppNumberFormat.score(current.score)} pts · '
                        '${AppNumberFormat.evaluations(current.evaluationCount)} · '
                        'Nível ${current.tier.label}',
                style: AppTextStyles.jakarta(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: .9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}