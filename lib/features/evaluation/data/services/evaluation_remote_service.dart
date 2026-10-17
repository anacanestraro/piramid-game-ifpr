import '../../../../core/result/result.dart';
import '../models/evaluation_model.dart';

// Acesso ao banco remoto de avaliações.
abstract class EvaluationRemoteService {
  // null quando o documento não existe.
  Future<Result<EvaluationModel?>> getById(String id);

  Future<Result<List<EvaluationModel>>> getByEvaluator(String evaluatorUid);

  Future<Result<List<EvaluationModel>>> getAll();

  Future<Result<void>> save(EvaluationModel evaluation);

  Future<Result<void>> deleteByPerson(String personId);
}