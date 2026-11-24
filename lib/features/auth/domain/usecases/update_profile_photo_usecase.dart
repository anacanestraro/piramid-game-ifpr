import '../../../../core/result/result.dart';
import '../entities/app_user.dart';
import '../entities/profile_photo.dart';
import '../repositories/auth_repository.dart';
import 'profile_photo_validator.dart';
import 'require_authenticated_user.dart';

// Trocar a foto de perfil do usuário logado.
// Cada usuário só altera a própria foto: o uid vem da sessão,
// nunca da tela.
class UpdateProfilePhotoUseCase {
  final AuthRepository _repository;
  final RequireAuthenticatedUser _requireUser;
  final ProfilePhotoValidator _validator;

  UpdateProfilePhotoUseCase(
    this._repository,
    this._requireUser, {
    ProfilePhotoValidator? validator,
  }) : _validator = validator ?? ProfilePhotoValidator();

  Future<Result<AppUser>> call(ProfilePhoto photo) async {
    final AppUser user;
    switch (await _requireUser()) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        user = value;
    }

    final validationError = _validator.validate(photo);
    if (validationError != null) {
      return Result.failure(validationError);
    }

    return _repository.updateProfilePhoto(
      uid: user.uid,
      bytes: photo.bytes,
      contentType: photo.contentType,
    );
  }
}