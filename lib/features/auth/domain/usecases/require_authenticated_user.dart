import '../../../../core/result/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

// Garante que existe um usuário logado antes de uma operação.
// Usado pelos use cases que precisam saber "quem está fazendo a ação".
class RequireAuthenticatedUser {
  final AuthRepository _repository;

  RequireAuthenticatedUser(this._repository);

  Future<Result<AppUser>> call() async {
    final result = await _repository.getCurrentUser();

    switch (result) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        if (value == null) {
          return const Result.failure(
            Failure('Você precisa estar logado para fazer isso.'),
          );
        }
        return Result.success(value);
    }
  }
}