import '../../../../core/result/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/usecases/require_authenticated_user.dart';
import '../entities/person.dart';
import '../entities/person_draft.dart';
import '../repositories/person_repository.dart';
import 'person_link_checker.dart';
import 'person_validator.dart';

// Alterar pessoa. Só quem cadastrou pode alterar.
class UpdatePersonUseCase {
  final PersonRepository _repository;
  final RequireAuthenticatedUser _requireUser;
  final PersonLinkChecker _linkChecker;
  final PersonValidator _validator;

  UpdatePersonUseCase(
    this._repository,
    this._requireUser, {
    PersonValidator? validator,
  })  : _linkChecker = PersonLinkChecker(_repository),
        _validator = validator ?? PersonValidator();

  Future<Result<void>> call(String personId, PersonDraft draft) async {
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
        Failure('Só quem cadastrou esta pessoa pode alterá-la.'),
      );
    }

    // Como só o criador edita, o vínculo é sempre com ele mesmo ou nenhum.
    final updated = current.copyWith(
      name: draft.name.trim(),
      nickname: draft.nickname.trim(),
      course: draft.course,
      classYear: draft.classYear,
      birthDate: draft.birthDate,
      linkedUserUid: draft.isMe ? user.uid : null,
      clearLinkedUser: !draft.isMe,
    );

    final validationError = _validator.validate(updated);
    if (validationError != null) {
      return Result.failure(validationError);
    }

    if (draft.isMe) {
      final linkError = await _linkChecker.ensureAccountIsFree(
        user.uid,
        exceptPersonId: current.id,
      );
      if (linkError != null) return Result.failure(linkError);
    }

    return _repository.update(updated);
  }
}