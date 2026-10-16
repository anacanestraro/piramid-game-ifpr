import '../../../../core/result/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/usecases/require_authenticated_user.dart';
import '../entities/person.dart';
import '../repositories/person_repository.dart';

// Remover pessoa. Só quem cadastrou pode remover.
class DeletePersonUseCase {
  final PersonRepository _repository;
  final RequireAuthenticatedUser _requireUser;

  DeletePersonUseCase(this._repository, this._requireUser);

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

    return _repository.delete(personId);
  }
}