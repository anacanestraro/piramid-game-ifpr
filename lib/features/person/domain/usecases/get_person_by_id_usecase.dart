import '../../../../core/result/result.dart';
import '../entities/person.dart';
import '../repositories/person_repository.dart';

// Buscar pessoa por identificador.
class GetPersonByIdUseCase {
  final PersonRepository _repository;

  GetPersonByIdUseCase(this._repository);

  Future<Result<Person>> call(String id) {
    return _repository.getById(id);
  }
}