import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../../core/command/command_state.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/ui/status_message.dart';
import '../../../domain/entities/ranking_entry.dart';
import '../../viewmodels/ranking_viewmodel.dart';
import '../../widgets/ranking_tile.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  RankingViewModel get _viewModel =>
      InjectionContainer.instance.rankingViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.refresh();
  }

  void _openPerson(RankingEntry entry) {
    // go (e não push): troca para a aba Pessoas já no detalhe,
    // com o botão de voltar levando à lista.
    context.go(AppRoutes.personDetail(entry.person.id));
  }

  @override
  Widget build(BuildContext context) {
    final dim = Theme.of(context).colorScheme.onSurface.withValues(alpha: .6);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding direito maior: os botões de tema/sair ficam por cima.
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 120, 0),
              child: Text('Ranking', style: AppTextStyles.screenTitle),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
              child: SignalBuilder(
                builder: (context) {
                  final selected = _viewModel.selectedView.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<RankingView>(
                        segments: const [
                          ButtonSegment(
                            value: RankingView.personal,
                            icon: Icon(Icons.person_rounded),
                            label: Text('Pessoal'),
                          ),
                          ButtonSegment(
                            value: RankingView.global,
                            icon: Icon(Icons.public_rounded),
                            label: Text('Global'),
                          ),
                        ],
                        selected: {selected},
                        onSelectionChanged: (selection) =>
                            _viewModel.selectedView.value = selection.first,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        selected == RankingView.personal
                            ? 'Na sua opinião: soma das notas que você deu.'
                            : 'Na opinião de todos: média das avaliações recebidas.',
                        style: AppTextStyles.jakarta(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: dim,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: SignalBuilder(builder: (context) => _buildList(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final isPersonal = _viewModel.selectedView.value == RankingView.personal;
    final CommandState loadState = isPersonal
        ? _viewModel.loadPersonalRankingCommand.state.value
        : _viewModel.loadGlobalRankingCommand.state.value;
    final ranking = _viewModel.visibleRanking.value;

    if (ranking.isEmpty && loadState.isRunning) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ranking.isEmpty && loadState.isError) {
      return StatusMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Não foi possível carregar o ranking',
        message: loadState.errorMessage,
        actionLabel: 'Tentar novamente',
        onAction: _viewModel.refresh,
      );
    }

    if (ranking.isEmpty) {
      return StatusMessage(
        icon: Icons.leaderboard_rounded,
        title: isPersonal
            ? 'Você ainda não avaliou ninguém'
            : 'Ninguém foi avaliado ainda',
        message: 'Abra uma pessoa e toque em "Avaliar" para entrar no ranking.',
        actionLabel: 'Ver pessoas',
        onAction: () => context.go(AppRoutes.people),
      );
    }

    return RefreshIndicator(
      onRefresh: _viewModel.refresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
        itemCount: ranking.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final entry = ranking[index];
          return RankingTile(
            entry: entry,
            showEvaluationCount: !isPersonal,
            onTap: () => _openPerson(entry),
          );
        },
      ),
    );
  }
}