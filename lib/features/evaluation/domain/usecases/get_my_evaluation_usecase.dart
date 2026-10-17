import '../../../../core/result/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/usecases/require_authenticated_user.dart';
import '../entities/evaluation.dart';
import '../repositories/evaluation_repository.dart';

// Consultar avaliação: a avaliação que o usuário logado fez de uma
// pessoa, ou null se ainda não avaliou.
class GetMyEvaluationUseCase {
  final EvaluationRepository _repository;
  final RequireAuthenticatedUser _requireUser;

  GetMyEvaluationUseCase(this._repository, this._requireUser);

  Future<Result<Evaluation?>> call(String personId) async {
    final AppUser user;
    switch (await _requireUser()) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        user = value;
    }

    return _repository.getById(
      Evaluation.idFor(evaluatorUid: user.uid, personId: personId),
    );
  }
}