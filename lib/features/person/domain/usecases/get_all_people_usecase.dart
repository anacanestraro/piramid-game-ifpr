import '../../../../core/result/result.dart';
import '../entities/person.dart';
import '../repositories/person_repository.dart';

// Buscar todas as pessoas.
class GetAllPeopleUseCase {
  final PersonRepository _repository;

  GetAllPeopleUseCase(this._repository);

  Future<Result<List<Person>>> call() {
    return _repository.getAll();
  }
}