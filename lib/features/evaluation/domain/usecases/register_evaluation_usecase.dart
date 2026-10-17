import '../../../../core/result/result.dart';
import '../entities/criteria_type.dart';
import '../entities/evaluation.dart';
import '../repositories/evaluation_repository.dart';
import 'evaluation_preconditions.dart';

// Registrar avaliação (seção 14.10).
// Recusa se o usuário já avaliou essa pessoa: nesse caso, ele deve
// alterar a avaliação existente (seção 16).
class RegisterEvaluationUseCase {
  final EvaluationRepository _repository;
  final EvaluationPreconditions _preconditions;

  RegisterEvaluationUseCase(this._repository, this._preconditions);

  Future<Result<Evaluation>> call(
    String personId,
    Map<CriteriaType, int> scores,
  ) async {
    final EvaluationContext context;
    switch (await _preconditions.check(personId, scores)) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        context = value;
    }

    final id = Evaluation.idFor(
      evaluatorUid: context.evaluator.uid,
      personId: personId,
    );

    switch (await _repository.getById(id)) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        if (value != null) {
          return Result.failure(Failure(
            'Você já avaliou ${context.person.name}. '
            'Altere a avaliação existente.',
          ));
        }
    }

    final evaluation = Evaluation(
      id: id,
      evaluatorUid: context.evaluator.uid,
      personId: personId,
      scores: Map.unmodifiable(scores),
      evaluatedAt: DateTime.now(),
    );

    switch (await _repository.save(evaluation)) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success():
        return Result.success(evaluation);
    }
  }
}