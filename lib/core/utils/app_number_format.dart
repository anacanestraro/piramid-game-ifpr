// Formatação de pontuações no padrão brasileiro (vírgula decimal).
class AppNumberFormat {
  AppNumberFormat._();

  // 65 -> "65" | 68.4 -> "68,4"
  static String score(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1).replaceAll('.', ',');
  }

  // 1 -> "1 avaliação" | 3 -> "3 avaliações"
  static String evaluations(int count) {
    return count == 1 ? '1 avaliação' : '$count avaliações';
  }
}