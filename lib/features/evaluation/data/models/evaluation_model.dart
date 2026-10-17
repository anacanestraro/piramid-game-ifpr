import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/criteria_type.dart';
import '../../domain/entities/evaluation.dart';

class EvaluationModelParseException implements Exception {
  final String message;
  const EvaluationModelParseException(this.message);

  @override
  String toString() => 'EvaluationModelParseException: $message';
}

// Envolve a entidade Evaluation, adicionando conversão de/para Firestore.
// O domínio (Evaluation) nunca conhece Firestore - só este Model conhece.
class EvaluationModel extends Evaluation {
  const EvaluationModel({
    required super.id,
    required super.evaluatorUid,
    required super.personId,
    required super.scores,
    required super.evaluatedAt,
  });

  factory EvaluationModel.fromEntity(Evaluation evaluation) {
    return EvaluationModel(
      id: evaluation.id,
      evaluatorUid: evaluation.evaluatorUid,
      personId: evaluation.personId,
      scores: evaluation.scores,
      evaluatedAt: evaluation.evaluatedAt,
    );
  }

  factory EvaluationModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    try {
      // Cada critério é um campo próprio no documento (ex.: "aura": 4).
      final scores = <CriteriaType, int>{};
      for (final criteria in CriteriaType.values) {
        final value = data[criteria.name];
        if (value is! num) {
          throw EvaluationModelParseException(
            'Nota ausente para "${criteria.name}"',
          );
        }
        scores[criteria] = value.toInt();
      }

      return EvaluationModel(
        id: id,
        evaluatorUid: data['evaluatorUid'] as String,
        personId: data['personId'] as String,
        scores: scores,
        evaluatedAt: (data['evaluatedAt'] as Timestamp).toDate(),
      );
    } on EvaluationModelParseException {
      rethrow;
    } catch (e) {
      throw EvaluationModelParseException(
        'Falha ao converter a avaliação "$id": $e',
      );
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'evaluatorUid': evaluatorUid,
      'personId': personId,
      for (final entry in scores.entries) entry.key.name: entry.value,
      // Gravado também (seção 9 pede a pontuação total armazenada),
      // mas o app sempre recalcula a partir das notas ao ler.
      'totalScore': totalScore,
      'evaluatedAt': Timestamp.fromDate(evaluatedAt),
    };
  }
}