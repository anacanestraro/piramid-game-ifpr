import 'package:signals/signals.dart';
import '../../../../core/command/command.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/person.dart';
import '../../facade/person_usecases_facade.dart';

class PeopleListViewModel {
  final PersonUseCasesFacade _facade;

  PeopleListViewModel(this._facade) {
    loadPeopleCommand = Command0<List<Person>>(_loadPeople);
  }

  late final Command0<List<Person>> loadPeopleCommand;

  final people = signal<List<Person>>([]);

  // Texto digitado na busca da lista.
  final searchTerm = signal('');

  // Lista filtrada por nome ou apelido, recalculada automaticamente
  // sempre que "people" ou "searchTerm" mudarem.
  late final Computed<List<Person>> filteredPeople = computed(() {
    final term = searchTerm.value.trim().toLowerCase();
    if (term.isEmpty) return people.value;

    return people.value.where((person) {
      return person.name.toLowerCase().contains(term) ||
          person.nickname.toLowerCase().contains(term);
    }).toList();
  });

  Future<void> refresh() => loadPeopleCommand.execute();

  Future<Result<List<Person>>> _loadPeople() async {
    final result = await _facade.getAll();

    result.when(
      onSuccess: (loaded) => people.value = loaded,
      // Mantém a lista anterior; o erro fica em loadPeopleCommand.state.
      onFailure: (_) {},
    );

    return result;
  }

  void dispose() {
    people.dispose();
    searchTerm.dispose();
    filteredPeople.dispose();
  }
}