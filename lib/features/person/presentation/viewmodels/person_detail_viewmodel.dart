import 'package:signals/signals.dart';
import '../../../../core/command/command.dart';
import '../../../../core/result/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/person.dart';
import '../../facade/person_usecases_facade.dart';

class PersonDetailViewModel {
  final PersonUseCasesFacade _facade;

  // Usuário da sessão, vindo da AuthViewModel. Recebe só o signal
  // (somente leitura), não a ViewModel inteira.
  final ReadonlySignal<AppUser?> _currentUser;

  PersonDetailViewModel(this._facade, this._currentUser) {
    loadPersonCommand = Command1<Person, String>(_loadPerson);
    removePersonCommand = Command0<void>(_removePerson);
  }

  late final Command1<Person, String> loadPersonCommand;
  late final Command0<void> removePersonCommand;

  final person = signal<Person?>(null);

  // Só usado para mostrar/esconder os botões de editar e remover.
  // Quem garante a regra de verdade é o use case.
  late final Computed<bool> canManage = computed(() {
    final current = person.value;
    final user = _currentUser.value;
    return current != null && user != null && current.wasCreatedBy(user.uid);
  });

  // A pessoa exibida é o próprio usuário logado?
  late final Computed<bool> isCurrentUser = computed(() {
    final current = person.value;
    final user = _currentUser.value;
    return current != null && user != null && current.isLinkedTo(user.uid);
  });

  Future<void> load(String personId) => loadPersonCommand.execute(personId);

  Future<Result<Person>> _loadPerson(String personId) async {
    // Limpa a pessoa anterior para não exibir dados de outra
    // enquanto a nova carrega.
    if (person.value?.id != personId) person.value = null;

    final result = await _facade.getById(personId);

    result.when(
      onSuccess: (loaded) => person.value = loaded,
      onFailure: (_) => person.value = null,
    );

    return result;
  }

  Future<Result<void>> _removePerson() async {
    final current = person.value;
    if (current == null) {
      return const Result.failure(Failure('Nenhuma pessoa selecionada.'));
    }

    final result = await _facade.delete(current.id);

    result.when(
      onSuccess: (_) => person.value = null,
      onFailure: (_) {},
    );

    return result;
  }

  void dispose() {
    person.dispose();
    canManage.dispose();
    isCurrentUser.dispose();
  }
}