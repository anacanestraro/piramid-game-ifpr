import '../../../../core/result/result.dart';
import '../../domain/entities/person.dart';
import '../../domain/repositories/person_repository.dart';
import '../models/person_model.dart';
import '../services/person_remote_service.dart';

class PersonRepositoryImpl implements PersonRepository {
  final PersonRemoteService _service;

  PersonRepositoryImpl(this._service);

  @override
  Future<Result<List<Person>>> getAll() {
    return _service.getAll();
  }

  @override
  Future<Result<Person>> getById(String id) async {
    final result = await _service.getById(id);

    switch (result) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        if (value == null) {
          return const Result.failure(Failure('Pessoa não encontrada.'));
        }
        return Result.success(value);
    }
  }

  @override
  Future<Result<Person?>> findLinkedTo(String uid) {
    return _service.findByLinkedUser(uid);
  }

  @override
  Future<Result<Person>> create(Person person) async {
    final result = await _service.create(PersonModel.fromEntity(person));

    switch (result) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        // Devolve a pessoa já com o id gerado pelo Firestore.
        return Result.success(person.copyWith(id: value));
    }
  }

  @override
  Future<Result<void>> update(Person person) {
    return _service.update(PersonModel.fromEntity(person));
  }

  @override
  Future<Result<void>> delete(String id) {
    return _service.delete(id);
  }
}