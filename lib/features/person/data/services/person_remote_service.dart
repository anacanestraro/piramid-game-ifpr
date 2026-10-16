import '../../../../core/result/result.dart';
import '../models/person_model.dart';

// Acesso ao banco remoto de pessoas.
abstract class PersonRemoteService {
  Future<Result<List<PersonModel>>> getAll();

  // null quando o documento não existe.
  Future<Result<PersonModel?>> getById(String id);

  Future<Result<PersonModel?>> findByLinkedUser(String uid);

  // Retorna o id gerado pelo banco.
  Future<Result<String>> create(PersonModel person);

  Future<Result<void>> update(PersonModel person);

  Future<Result<void>> delete(String id);
}