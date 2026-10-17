import '../../../../core/result/result.dart';
import '../entities/criteria_type.dart';
import '../entities/evaluation.dart';
import '../repositories/evaluation_repository.dart';
import 'evaluation_preconditions.dart';

// Alterar avaliação (seção 14.11).
// Só altera uma avaliação que o próprio usuário já fez.
class UpdateEvaluationUseCase {
  final EvaluationRepository _repository;
  final EvaluationPreconditions _preconditions;

  UpdateEvaluationUseCase(this._repository, this._preconditions);

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

    final Evaluation existing;
    switch (await _repository.getById(id)) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        if (value == null) {
          return Result.failure(Failure(
            'Você ainda não avaliou ${context.person.name}.',
          ));
        }
        existing = value;
    }

    final updated = existing.copyWith(
      scores: Map.unmodifiable(scores),
      evaluatedAt: DateTime.now(),
    );

    switch (await _repository.save(updated)) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success():
        return Result.success(updated);
    }
  }
}