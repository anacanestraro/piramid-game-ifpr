import '../../../../core/result/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/usecases/require_authenticated_user.dart';
import '../../../evaluation/domain/repositories/evaluation_repository.dart';
import '../../../person/domain/repositories/person_repository.dart';
import '../entities/ranking_entry.dart';
import 'ranking_calculator.dart';

// Calcular ranking pessoal (seção 14.13).
class CalculatePersonalRankingUseCase {
  final EvaluationRepository _evaluationRepository;
  final PersonRepository _personRepository;
  final RequireAuthenticatedUser _requireUser;
  final RankingCalculator _calculator;

  CalculatePersonalRankingUseCase(
    this._evaluationRepository,
    this._personRepository,
    this._requireUser, {
    this._calculator = const RankingCalculator(),
  });

  Future<Result<List<RankingEntry>>> call() async {
    final AppUser user;
    switch (await _requireUser()) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        user = value;
    }

    // Avaliações do usuário e pessoas são buscadas ao mesmo tempo.
    final (evaluationsResult, peopleResult) = await (
      _evaluationRepository.getByEvaluator(user.uid),
      _personRepository.getAll(),
    ).wait;

    switch ((evaluationsResult, peopleResult)) {
      case (ResultFailure(:final failure), _):
      case (_, ResultFailure(:final failure)):
        return Result.failure(failure);
      case (Success(value: final evaluations), Success(value: final people)):
        return Result.success(
          _calculator.personal(myEvaluations: evaluations, people: people),
        );
    }
  }
}