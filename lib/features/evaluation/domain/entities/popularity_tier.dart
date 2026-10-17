// Classificação pela pontuação (Nível Lenda vai de 15 a 75).
enum PopularityTier { novato, popular, idolo, lenda }

extension PopularityTierInfo on PopularityTier {
  String get label {
    switch (this) {
      case PopularityTier.novato:
        return 'Novato';
      case PopularityTier.popular:
        return 'Popular';
      case PopularityTier.idolo:
        return 'Ídolo';
      case PopularityTier.lenda:
        return 'Lenda';
    }
  }

  // double para servir tanto à soma de uma avaliação
  // quanto à média do ranking global.
  static PopularityTier fromScore(double score) {
    if (score >= 61) return PopularityTier.lenda;
    if (score >= 46) return PopularityTier.idolo;
    if (score >= 31) return PopularityTier.popular;
    return PopularityTier.novato;
  }
}