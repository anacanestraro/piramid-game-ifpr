import 'package:signals/signals.dart';
import '../../../../core/command/command.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/ranking_entry.dart';
import '../../facade/ranking_usecases_facade.dart';

// Qual ranking está sendo exibido na tela.
enum RankingView { personal, global }

class RankingViewModel {
  final RankingUseCasesFacade _facade;

  RankingViewModel(this._facade) {
    loadPersonalRankingCommand =
        Command0<List<RankingEntry>>(_loadPersonal);
    loadGlobalRankingCommand = Command0<List<RankingEntry>>(_loadGlobal);
  }

  // carregarRankingPessoalCommand / carregarRankingGlobalCommand (seção 4.5).
  late final Command0<List<RankingEntry>> loadPersonalRankingCommand;
  late final Command0<List<RankingEntry>> loadGlobalRankingCommand;

  final personalRanking = signal<List<RankingEntry>>([]);
  final globalRanking = signal<List<RankingEntry>>([]);

  // Fica na ViewModel para a escolha sobreviver à troca de abas.
  final selectedView = signal(RankingView.global);

  // Ranking exibido conforme a aba escolhida.
  late final Computed<List<RankingEntry>> visibleRanking = computed(() {
    return selectedView.value == RankingView.personal
        ? personalRanking.value
        : globalRanking.value;
  });

  // Líder geral (usado na tela inicial).
  late final Computed<RankingEntry?> globalLeader = computed(() {
    final ranking = globalRanking.value;
    return ranking.isEmpty ? null : ranking.first;
  });

  // Quantas pessoas o usuário logado já avaliou.
  late final Computed<int> myEvaluationCount =
      computed(() => personalRanking.value.length);

  // Carrega os dois rankings ao mesmo tempo.
  Future<void> refresh() async {
    await Future.wait([
      loadPersonalRankingCommand.execute(),
      loadGlobalRankingCommand.execute(),
    ]);
  }

  Future<Result<List<RankingEntry>>> _loadPersonal() async {
    final result = await _facade.personalRanking();
    result.when(
      onSuccess: (ranking) => personalRanking.value = ranking,
      // Mantém o ranking anterior; o erro fica no state do command.
      onFailure: (_) {},
    );
    return result;
  }

  Future<Result<List<RankingEntry>>> _loadGlobal() async {
    final result = await _facade.globalRanking();
    result.when(
      onSuccess: (ranking) => globalRanking.value = ranking,
      onFailure: (_) {},
    );
    return result;
  }

  // Limpa os dados ao sair da conta, para o próximo usuário
  // não ver por um instante o ranking pessoal de quem saiu.
  void clear() {
    batch(() {
      personalRanking.value = [];
      globalRanking.value = [];
      selectedView.value = RankingView.global;
    });
  }

  void dispose() {
    personalRanking.dispose();
    globalRanking.dispose();
    selectedView.dispose();
    visibleRanking.dispose();
    globalLeader.dispose();
    myEvaluationCount.dispose();
  }
}