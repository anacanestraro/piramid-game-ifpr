import 'package:signals/signals.dart';
import '../../../../core/command/command.dart';
import '../../../../core/command/command_state.dart';
import '../../../../core/result/result.dart';
import '../../../person/domain/entities/person.dart';
import '../../../person/facade/person_usecases_facade.dart';
import '../../domain/entities/criteria_type.dart';
import '../../domain/entities/evaluation.dart';
import '../../domain/entities/popularity_tier.dart';
import '../../facade/evaluation_usecases_facade.dart';

class EvaluationFormViewModel {
  final EvaluationUseCasesFacade _evaluationFacade;
  final PersonUseCasesFacade _personFacade;

  EvaluationFormViewModel(this._evaluationFacade, this._personFacade) {
    loadCommand = Command1<void, String>(_load);
    evaluatePersonCommand = Command0<Evaluation>(_evaluate);
  }

  late final Command1<void, String> loadCommand;
  late final Command0<Evaluation> evaluatePersonCommand;

  String? _personId;

  // Pessoa sendo avaliada.
  final person = signal<Person?>(null);

  // Avaliação que o usuário já fez dessa pessoa (null = primeira vez).
  final existing = signal<Evaluation?>(null);

  // A pessoa é o próprio usuário? Nesse caso a avaliação é bloqueada.
  final isSelf = signal(false);

  // Uma nota por critério. 0 = ainda não avaliado.
  final Map<CriteriaType, Signal<int>> scores = {
    for (final criteria in CriteriaType.values) criteria: signal(0),
  };

  late final Computed<bool> isEditing =
      computed(() => existing.value != null);

  late final Computed<int> totalScore = computed(
    () => scores.values.fold(0, (sum, score) => sum + score.value),
  );

  late final Computed<int> ratedCount = computed(
    () => scores.values.where((score) => score.value > 0).length,
  );

  late final Computed<bool> isComplete =
      computed(() => ratedCount.value == CriteriaType.values.length);

  late final Computed<PopularityTier> tier = computed(
    () => PopularityTierInfo.fromScore(totalScore.value.toDouble()),
  );

  void setScore(CriteriaType criteria, int value) {
    scores[criteria]!.value = value;
  }

  Future<void> load(String personId) => loadCommand.execute(personId);

  Future<Result<void>> _load(String personId) async {
    _personId = personId;
    evaluatePersonCommand.state.value = const CommandState();

    batch(() {
      person.value = null;
      existing.value = null;
      isSelf.value = false;
      for (final score in scores.values) {
        score.value = 0;
      }
    });

    // As três consultas são independentes: rodam ao mesmo tempo.
    final (personResult, selfResult, mineResult) = await (
      _personFacade.getById(personId),
      _evaluationFacade.isSelfEvaluation(personId),
      _evaluationFacade.getMine(personId),
    ).wait;

    switch (personResult) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        person.value = value;
    }

    switch (selfResult) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        isSelf.value = value;
    }

    switch (mineResult) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        existing.value = value;
        if (value != null) _fillScores(value);
    }

    return const Result.success(null);
  }

  // Avaliar pela primeira vez ou alterar a avaliação existente.
  Future<Result<Evaluation>> _evaluate() async {
    final personId = _personId;
    if (personId == null) {
      return const Result.failure(Failure('Nenhuma pessoa selecionada.'));
    }

    final currentScores = {
      for (final entry in scores.entries) entry.key: entry.value.value,
    };

    final result = isEditing.value
        ? await _evaluationFacade.update(personId, currentScores)
        : await _evaluationFacade.register(personId, currentScores);

    result.when(
      // Depois de salvar, a próxima gravação passa a ser "alterar".
      onSuccess: (saved) => existing.value = saved,
      onFailure: (_) {},
    );

    return result;
  }

  void _fillScores(Evaluation evaluation) {
    batch(() {
      for (final entry in evaluation.scores.entries) {
        scores[entry.key]!.value = entry.value;
      }
    });
  }

  void dispose() {
    person.dispose();
    existing.dispose();
    isSelf.dispose();
    for (final score in scores.values) {
      score.dispose();
    }
    isEditing.dispose();
    totalScore.dispose();
    ratedCount.dispose();
    isComplete.dispose();
    tier.dispose();
  }
}