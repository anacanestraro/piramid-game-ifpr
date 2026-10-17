import 'criteria_type.dart';

// Avaliação que um usuário faz de uma pessoa (seção 9).
// Regra: usuário + pessoa = uma única avaliação.
class Evaluation {
  final String id;
  final String evaluatorUid;
  final String personId;
  final Map<CriteriaType, int> scores;
  final DateTime evaluatedAt;

  const Evaluation({
    required this.id,
    required this.evaluatorUid,
    required this.personId,
    required this.scores,
    required this.evaluatedAt,
  });

  // O id é sempre derivado de quem avaliou + quem foi avaliado.
  // Assim, avaliar de novo a mesma pessoa aponta para o mesmo registro,
  // e o banco nunca guarda duas avaliações do mesmo par.
  static String idFor({
    required String evaluatorUid,
    required String personId,
  }) {
    return '${evaluatorUid}_$personId';
  }

  // Soma das 15 notas = Nível Lenda desta avaliação.
  int get totalScore => scores.values.fold(0, (sum, score) => sum + score);

  Evaluation copyWith({
    Map<CriteriaType, int>? scores,
    DateTime? evaluatedAt,
  }) {
    return Evaluation(
      id: id,
      evaluatorUid: evaluatorUid,
      personId: personId,
      scores: scores ?? this.scores,
      evaluatedAt: evaluatedAt ?? this.evaluatedAt,
    );
  }
}