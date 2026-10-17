import '../../../core/result/result.dart';
import '../domain/entities/criteria_type.dart';
import '../domain/entities/evaluation.dart';
import '../domain/usecases/check_self_evaluation_usecase.dart';
import '../domain/usecases/get_my_evaluation_usecase.dart';
import '../domain/usecases/get_my_evaluations_usecase.dart';
import '../domain/usecases/register_evaluation_usecase.dart';
import '../domain/usecases/update_evaluation_usecase.dart';

// Agrupa os use cases de avaliação (seção 4.4 da especificação).
class EvaluationUseCasesFacade {
  final RegisterEvaluationUseCase _register;
  final UpdateEvaluationUseCase _update;
  final GetMyEvaluationUseCase _getMine;
  final GetMyEvaluationsUseCase _getAllMine;
  final CheckSelfEvaluationUseCase _checkSelf;

  EvaluationUseCasesFacade({
    required this._register,
    required this._update,
    required this._getMine,
    required this._getAllMine,
    required this._checkSelf,
  });

  Future<Result<Evaluation>> register(
    String personId,
    Map<CriteriaType, int> scores,
  ) =>
      _register(personId, scores);

  Future<Result<Evaluation>> update(
    String personId,
    Map<CriteriaType, int> scores,
  ) =>
      _update(personId, scores);

  Future<Result<Evaluation?>> getMine(String personId) => _getMine(personId);

  Future<Result<List<Evaluation>>> getAllMine() => _getAllMine();

  Future<Result<bool>> isSelfEvaluation(String personId) =>
      _checkSelf(personId);
}