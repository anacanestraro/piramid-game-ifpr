import '../../../../core/result/result.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/domain/usecases/require_authenticated_user.dart';
import '../../../person/domain/entities/person.dart';
import '../../../person/domain/repositories/person_repository.dart';

// Verificar tentativa de autoavaliação (seção 14.12).
// Retorna true se a pessoa informada é o próprio usuário logado.
// A tela usa para esconder o botão "Avaliar"; os use cases de
// registrar/alterar aplicam a mesma regra por conta própria.
class CheckSelfEvaluationUseCase {
  final RequireAuthenticatedUser _requireUser;
  final PersonRepository _personRepository;

  CheckSelfEvaluationUseCase(this._requireUser, this._personRepository);

  Future<Result<bool>> call(String personId) async {
    final AppUser user;
    switch (await _requireUser()) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        user = value;
    }

    final Person person;
    switch (await _personRepository.getById(personId)) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        person = value;
    }

    return Result.success(person.isLinkedTo(user.uid));
  }
}