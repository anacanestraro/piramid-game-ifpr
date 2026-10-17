import '../../../../core/result/result.dart';
import '../entities/evaluation.dart';

// Contrato usado pelos use cases. Não conhece Firestore nem EvaluationModel.
abstract class EvaluationRepository {
  // null quando o usuário ainda não avaliou a pessoa.
  Future<Result<Evaluation?>> getById(String id);

  // Avaliações feitas por um usuário (ranking pessoal).
  Future<Result<List<Evaluation>>> getByEvaluator(String evaluatorUid);

  // Todas as avaliações de todos os usuários (ranking global).
  Future<Result<List<Evaluation>>> getAll();

  // Grava a avaliação no id dela (cria ou sobrescreve).
  Future<Result<void>> save(Evaluation evaluation);

  // Remove todas as avaliações recebidas por uma pessoa.
  Future<Result<void>> deleteByPerson(String personId);
}