import '../../../core/result/result.dart';
import '../domain/entities/person.dart';
import '../domain/entities/person_draft.dart';
import '../domain/usecases/create_person_usecase.dart';
import '../domain/usecases/delete_person_usecase.dart';
import '../domain/usecases/get_all_people_usecase.dart';
import '../domain/usecases/get_person_by_id_usecase.dart';
import '../domain/usecases/update_person_usecase.dart';

// Agrupa os use cases de pessoa (seção 4.4 da especificação).
class PersonUseCasesFacade {
  final CreatePersonUseCase _create;
  final UpdatePersonUseCase _update;
  final DeletePersonUseCase _delete;
  final GetAllPeopleUseCase _getAll;
  final GetPersonByIdUseCase _getById;

  PersonUseCasesFacade({
    required this._create,
    required this._update,
    required this._delete,
    required this._getAll,
    required this._getById,
  });

  Future<Result<Person>> create(PersonDraft draft) => _create(draft);

  Future<Result<void>> update(String personId, PersonDraft draft) =>
      _update(personId, draft);

  Future<Result<void>> delete(String personId) => _delete(personId);

  Future<Result<List<Person>>> getAll() => _getAll();

  Future<Result<Person>> getById(String id) => _getById(id);
}