import '../../../../core/result/result.dart';
import '../repositories/person_repository.dart';

// Regra: cada conta pode estar vinculada a no máximo uma pessoa.
// Compartilhada entre cadastrar e alterar.
class PersonLinkChecker {
  final PersonRepository _repository;

  PersonLinkChecker(this._repository);

  // Retorna null se a conta estiver livre, ou uma Failure se já houver
  // outra pessoa vinculada a ela. exceptPersonId permite que a própria
  // pessoa em edição continue vinculada.
  Future<Failure?> ensureAccountIsFree(
    String uid, {
    String? exceptPersonId,
  }) async {
    final result = await _repository.findLinkedTo(uid);

    switch (result) {
      case ResultFailure(:final failure):
        return failure;
      case Success(:final value):
        if (value != null && value.id != exceptPersonId) {
          return Failure('Sua conta já está vinculada a "${value.name}".');
        }
        return null;
    }
  }
}