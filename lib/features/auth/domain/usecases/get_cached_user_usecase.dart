import '../../../../core/result/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

// Último usuário salvo no dispositivo, para exibir na abertura do app.
// Não serve para liberar acesso: isso é papel do GetCurrentUserUseCase.
class GetCachedUserUseCase {
  final AuthRepository _repository;

  GetCachedUserUseCase(this._repository);

  Future<Result<AppUser?>> call() => _repository.getCachedUser();
}