import '../../../../core/result/result.dart';
import '../repositories/auth_repository.dart';

// Realizar logout.
class SignOutUseCase {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  Future<Result<void>> call() {
    return _repository.signOut();
  }
}