import '../../../evaluation/domain/entities/popularity_tier.dart';
import '../../../person/domain/entities/person.dart';

// Uma linha do ranking: posição, pessoa, pontuação e nº de avaliações.
class RankingEntry {
  final int position;
  final Person person;

  // Pessoal: soma da avaliação do usuário (15 a 75).
  // Global: média das avaliações recebidas.
  final double score;

  final int evaluationCount;

  const RankingEntry({
    required this.position,
    required this.person,
    required this.score,
    required this.evaluationCount,
  });

  PopularityTier get tier => PopularityTierInfo.fromScore(score);
}