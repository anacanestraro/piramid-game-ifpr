// Iniciais de um nome para avatares (ex.: "João Pedro Silva" -> "JS").
// Fica no core para qualquer avatar do app usar a mesma regra.
class NameInitials {
  NameInitials._();

  static String of(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}