import '../../../../core/result/result.dart';
import '../entities/criteria_type.dart';

// Regras das notas (seção 16): todos os critérios avaliados,
// nenhuma nota menor que 1 nem maior que 5.
class EvaluationValidator {
  Failure? validateScores(Map<CriteriaType, int> scores) {
    final missing = CriteriaType.values.where((c) => !scores.containsKey(c));

    if (missing.isNotEmpty) {
      return Failure(
        'Avalie todos os ${CriteriaType.values.length} critérios. '
        'Falta: ${missing.first.label}.',
      );
    }

    for (final entry in scores.entries) {
      if (entry.value < CriteriaScoreLimits.min ||
          entry.value > CriteriaScoreLimits.max) {
        return Failure(
          '${entry.key.label} deve ter nota entre '
          '${CriteriaScoreLimits.min} e ${CriteriaScoreLimits.max}.',
        );
      }
    }

    return null;
  }
}