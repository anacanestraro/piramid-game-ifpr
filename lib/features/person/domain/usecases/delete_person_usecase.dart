import '../../../../core/result/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/usecases/require_authenticated_user.dart';
import '../../../evaluation/domain/repositories/evaluation_repository.dart';
import '../entities/person.dart';
import '../repositories/person_repository.dart';

// Remover pessoa. Só quem cadastrou pode remover.
// Remove também as avaliações recebidas por ela.
class DeletePersonUseCase {
  final PersonRepository _repository;
  final EvaluationRepository _evaluationRepository;
  final RequireAuthenticatedUser _requireUser;

  DeletePersonUseCase(
    this._repository,
    this._evaluationRepository,
    this._requireUser,
  );

  Future<Result<void>> call(String personId) async {
    final AppUser user;
    switch (await _requireUser()) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        user = value;
    }

    final Person current;
    switch (await _repository.getById(personId)) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        current = value;
    }

    if (!current.wasCreatedBy(user.uid)) {
      return const Result.failure(
        Failure('Só quem cadastrou esta pessoa pode removê-la.'),
      );
    }

    final deleteResult = await _repository.delete(personId);
    if (deleteResult is ResultFailure) return deleteResult;

    // Ordem proposital: primeiro a pessoa, depois as avaliações.
    // Se esta etapa falhar, sobram avaliações "órfãs", que o ranking
    // ignora por não encontrar a pessoa. O contrário (apagar as notas e
    // falhar ao apagar a pessoa) faria a pessoa perder as avaliações.
    await _evaluationRepository.deleteByPerson(personId);

    return const Result.success(null);
  }
}