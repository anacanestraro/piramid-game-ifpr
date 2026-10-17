import '../../../../core/result/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/usecases/require_authenticated_user.dart';
import '../entities/evaluation.dart';
import '../repositories/evaluation_repository.dart';

// Buscar as avaliações realizadas pelo usuário autenticado.
class GetMyEvaluationsUseCase {
  final EvaluationRepository _repository;
  final RequireAuthenticatedUser _requireUser;

  GetMyEvaluationsUseCase(this._repository, this._requireUser);

  Future<Result<List<Evaluation>>> call() async {
    final AppUser user;
    switch (await _requireUser()) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        user = value;
    }

    return _repository.getByEvaluator(user.uid);
  }
}