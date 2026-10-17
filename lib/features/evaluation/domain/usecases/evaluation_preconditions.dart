import '../../../../core/result/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/usecases/require_authenticated_user.dart';
import '../../../person/domain/entities/person.dart';
import '../../../person/domain/repositories/person_repository.dart';
import '../entities/criteria_type.dart';
import 'evaluation_validator.dart';

// Quem avalia e quem é avaliado, já verificados.
typedef EvaluationContext = ({AppUser evaluator, Person person});

// Verificações comuns a registrar e alterar uma avaliação (seção 16):
// usuário logado, pessoa existente, sem autoavaliação e notas válidas.
class EvaluationPreconditions {
  final RequireAuthenticatedUser _requireUser;
  final PersonRepository _personRepository;
  final EvaluationValidator _validator;

  EvaluationPreconditions(
    this._requireUser,
    this._personRepository, {
    EvaluationValidator? validator,
  }) : _validator = validator ?? EvaluationValidator();

  Future<Result<EvaluationContext>> check(
    String personId,
    Map<CriteriaType, int> scores,
  ) async {
    final AppUser evaluator;
    switch (await _requireUser()) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        evaluator = value;
    }

    final Person person;
    switch (await _personRepository.getById(personId)) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        person = value;
    }

    if (person.isLinkedTo(evaluator.uid)) {
      return const Result.failure(Failure('Você não pode avaliar a si mesmo.'));
    }

    final scoresError = _validator.validateScores(scores);
    if (scoresError != null) return Result.failure(scoresError);

    return Result.success((evaluator: evaluator, person: person));
  }
}