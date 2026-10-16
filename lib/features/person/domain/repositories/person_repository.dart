import '../../../../core/result/result.dart';
import '../entities/person.dart';

// Contrato usado pelos use cases. Não conhece Firestore nem PersonModel.
abstract class PersonRepository {
  Future<Result<List<Person>>> getAll();

  Future<Result<Person>> getById(String id);

  // Pessoa vinculada a uma conta, ou null se a conta não tiver vínculo.
  Future<Result<Person?>> findLinkedTo(String uid);

  // Retorna a pessoa já com o id gerado pelo banco.
  Future<Result<Person>> create(Person person);

  Future<Result<void>> update(Person person);

  Future<Result<void>> delete(String id);
}