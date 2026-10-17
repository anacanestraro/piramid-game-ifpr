import '../../../evaluation/domain/entities/evaluation.dart';
import '../../../person/domain/entities/person.dart';
import '../entities/ranking_entry.dart';

// Cálculo puro dos rankings: recebe listas e devolve o ranking.
// Não acessa banco nem Firebase, então pode ser testado isoladamente.
class RankingCalculator {
  const RankingCalculator();

  // Ranking pessoal (seção 12): só as avaliações de um usuário.
  // A pontuação de cada pessoa é a soma da avaliação dele.
  List<RankingEntry> personal({
    required List<Evaluation> myEvaluations,
    required List<Person> people,
  }) {
    final peopleById = _indexById(people);

    final scored = <_ScoredPerson>[];
    for (final evaluation in myEvaluations) {
      final person = peopleById[evaluation.personId];
      // Avaliação de pessoa já removida: ignorada.
      if (person == null) continue;

      scored.add(_ScoredPerson(
        person: person,
        score: evaluation.totalScore.toDouble(),
        evaluationCount: 1,
      ));
    }

    return _rank(scored);
  }

  // Ranking global (seção 13): avaliações de todos os usuários.
  // A pontuação de cada pessoa é a média das avaliações recebidas.
  List<RankingEntry> global({
    required List<Evaluation> allEvaluations,
    required List<Person> people,
  }) {
    final peopleById = _indexById(people);

    // Agrupa as pontuações por pessoa avaliada.
    final totalsByPerson = <String, List<int>>{};
    for (final evaluation in allEvaluations) {
      if (!peopleById.containsKey(evaluation.personId)) continue;
      totalsByPerson
          .putIfAbsent(evaluation.personId, () => [])
          .add(evaluation.totalScore);
    }

    final scored = totalsByPerson.entries.map((entry) {
      final totals = entry.value;
      final sum = totals.fold(0, (acc, total) => acc + total);

      return _ScoredPerson(
        person: peopleById[entry.key]!,
        score: sum / totals.length,
        evaluationCount: totals.length,
      );
    }).toList();

    return _rank(scored);
  }

  Map<String, Person> _indexById(List<Person> people) {
    return {for (final person in people) person.id: person};
  }

  // Ordena da maior pontuação para a menor e numera as posições.
  // Empates dividem a posição (1º, 1º, 3º), como em competições.
  List<RankingEntry> _rank(List<_ScoredPerson> scored) {
    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      // Desempate só para a ordem de exibição ficar estável.
      return a.person.name.toLowerCase().compareTo(b.person.name.toLowerCase());
    });

    final entries = <RankingEntry>[];
    for (var i = 0; i < scored.length; i++) {
      final current = scored[i];
      final isTie = i > 0 && current.score == scored[i - 1].score;
      final position = isTie ? entries[i - 1].position : i + 1;

      entries.add(RankingEntry(
        position: position,
        person: current.person,
        score: current.score,
        evaluationCount: current.evaluationCount,
      ));
    }

    return entries;
  }
}

class _ScoredPerson {
  final Person person;
  final double score;
  final int evaluationCount;

  const _ScoredPerson({
    required this.person,
    required this.score,
    required this.evaluationCount,
  });
}