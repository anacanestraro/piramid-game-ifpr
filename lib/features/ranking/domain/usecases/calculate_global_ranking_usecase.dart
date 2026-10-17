import '../../../../core/result/result.dart';
import '../../../auth/domain/usecases/require_authenticated_user.dart';
import '../../../evaluation/domain/repositories/evaluation_repository.dart';
import '../../../person/domain/repositories/person_repository.dart';
import '../entities/ranking_entry.dart';
import 'ranking_calculator.dart';

// Calcular ranking global (seção 14.14).
class CalculateGlobalRankingUseCase {
  final EvaluationRepository _evaluationRepository;
  final PersonRepository _personRepository;
  final RequireAuthenticatedUser _requireUser;
  final RankingCalculator _calculator;

  CalculateGlobalRankingUseCase(
    this._evaluationRepository,
    this._personRepository,
    this._requireUser, {
    this._calculator = const RankingCalculator(),
  });

  Future<Result<List<RankingEntry>>> call() async {
    // O global não depende de quem está logado, mas só usuários
    // autenticados podem consultá-lo.
    final userResult = await _requireUser();
    if (userResult case ResultFailure(:final failure)) {
      return Result.failure(failure);
    }

    final (evaluationsResult, peopleResult) = await (
      _evaluationRepository.getAll(),
      _personRepository.getAll(),
    ).wait;

    switch ((evaluationsResult, peopleResult)) {
      case (ResultFailure(:final failure), _):
      case (_, ResultFailure(:final failure)):
        return Result.failure(failure);
      case (Success(value: final evaluations), Success(value: final people)):
        return Result.success(
          _calculator.global(allEvaluations: evaluations, people: people),
        );
    }
  }
}