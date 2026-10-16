import '../../../../core/result/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

// Verificar usuário autenticado: retorna o usuário com sessão
// válida, ou null se ninguém estiver logado.
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Result<AppUser?>> call() {
    return _repository.getCurrentUser();
  }
}