import 'package:signals/signals.dart';
import '../../../../core/command/command.dart';
import '../../../../core/command/command_state.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/person.dart';
import '../../domain/entities/person_draft.dart';
import '../../domain/usecases/person_validator.dart';
import '../../facade/person_usecases_facade.dart';

class PersonFormViewModel {
  final PersonUseCasesFacade _facade;

  PersonFormViewModel(this._facade) {
    loadPersonCommand = Command1<Person, String>(_loadPerson);
    createPersonCommand = Command0<Person>(_createPerson);
    updatePersonCommand = Command0<void>(_updatePerson);
  }

  late final Command1<Person, String> loadPersonCommand;
  late final Command0<Person> createPersonCommand;
  late final Command0<void> updatePersonCommand;

  // Id da pessoa em edição, ou null quando é um cadastro novo.
  final editingPersonId = signal<String?>(null);

  // Campos do formulário.
  final name = signal('');
  final nickname = signal('');
  final course = signal(Course.info);
  final classYear = signal(_defaultClassYear);
  final birthDate = signal<DateTime?>(null);
  final isMe = signal(false);

  // Muda sempre que o formulário é preenchido de fora (novo ou edição),
  // para a tela recriar os campos de texto com os valores certos.
  final formVersion = signal(0);

  late final Computed<bool> isEditing =
      computed(() => editingPersonId.value != null);

  late final Computed<bool> isSaving = computed(() =>
      createPersonCommand.state.value.isRunning ||
      updatePersonCommand.state.value.isRunning);

  // Habilita o botão de salvar. A validação completa é feita no use case.
  late final Computed<bool> canSubmit = computed(() =>
      name.value.trim().isNotEmpty &&
      nickname.value.trim().isNotEmpty &&
      birthDate.value != null);

  static int get _defaultClassYear {
    final year = DateTime.now().year;
    return year > PersonValidator.maxClassYear
        ? PersonValidator.maxClassYear
        : year;
  }

  // Prepara o formulário para um cadastro novo.
  void startNew() {
    editingPersonId.value = null;
    name.value = '';
    nickname.value = '';
    course.value = Course.info;
    classYear.value = _defaultClassYear;
    birthDate.value = null;
    isMe.value = false;
    _resetCommandStates();
    formVersion.value++;
  }

  // Prepara o formulário para editar uma pessoa existente.
  Future<void> startEditing(String personId) async {
    _resetCommandStates();
    await loadPersonCommand.execute(personId);
  }

  // Cadastra ou altera, conforme o modo atual.
  // Retorna o estado final para a tela decidir o que mostrar.
  Future<CommandState> save() async {
    if (isEditing.value) {
      await updatePersonCommand.execute();
      return updatePersonCommand.state.value;
    }

    await createPersonCommand.execute();
    return createPersonCommand.state.value;
  }

  Future<Result<Person>> _loadPerson(String personId) async {
    final result = await _facade.getById(personId);

    result.when(
      onSuccess: (person) {
        editingPersonId.value = person.id;
        name.value = person.name;
        nickname.value = person.nickname;
        course.value = person.course;
        classYear.value = person.classYear;
        birthDate.value = person.birthDate;
        isMe.value = person.linkedUserUid != null;
        formVersion.value++;
      },
      onFailure: (_) {},
    );

    return result;
  }

  Future<Result<Person>> _createPerson() async {
    final draft = _buildDraft();
    if (draft == null) return const Result.failure(_missingBirthDate);
    return _facade.create(draft);
  }

  Future<Result<void>> _updatePerson() async {
    final personId = editingPersonId.value;
    if (personId == null) {
      return const Result.failure(Failure('Nenhuma pessoa em edição.'));
    }

    final draft = _buildDraft();
    if (draft == null) return const Result.failure(_missingBirthDate);
    return _facade.update(personId, draft);
  }

  static const _missingBirthDate =
      Failure('Selecione a data de nascimento.');

  // Monta os dados do formulário. Retorna null se faltar a data,
  // que é o único campo que não tem valor padrão.
  PersonDraft? _buildDraft() {
    final selectedBirthDate = birthDate.value;
    if (selectedBirthDate == null) return null;

    return PersonDraft(
      name: name.value,
      nickname: nickname.value,
      course: course.value,
      classYear: classYear.value,
      birthDate: selectedBirthDate,
      isMe: isMe.value,
    );
  }

  void _resetCommandStates() {
    loadPersonCommand.state.value = const CommandState();
    createPersonCommand.state.value = const CommandState();
    updatePersonCommand.state.value = const CommandState();
  }

  void dispose() {
    editingPersonId.dispose();
    name.dispose();
    nickname.dispose();
    course.dispose();
    classYear.dispose();
    birthDate.dispose();
    isMe.dispose();
    formVersion.dispose();
    isEditing.dispose();
    isSaving.dispose();
    canSubmit.dispose();
  }
}