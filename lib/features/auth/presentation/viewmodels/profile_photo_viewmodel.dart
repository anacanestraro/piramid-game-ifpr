import 'package:signals/signals.dart';
import '../../../../core/command/command.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/profile_photo.dart';
import '../../facade/auth_usecases_facade.dart';
import '../services/profile_photo_picker.dart';

// Troca da foto de perfil do usuário logado.
// Separada da AuthViewModel para cada ViewModel ter uma única
// responsabilidade: a AuthViewModel cuida da sessão, esta da foto.
class ProfilePhotoViewModel {
  final AuthUseCasesFacade _facade;
  final ProfilePhotoPicker _picker;

  // Signal do usuário da sessão, vindo da AuthViewModel. Atualizá-lo
  // faz a foto nova aparecer em todas as telas que o observam.
  final Signal<AppUser?> _currentUser;

  ProfilePhotoViewModel(this._facade, this._picker, this._currentUser) {
    pickFromGalleryCommand = Command0<AppUser?>(_pickFromGallery);
    savePhotoCommand = Command1<AppUser, ProfilePhoto>(_savePhoto);
  }

  // Galeria: abre o seletor e já envia a imagem escolhida.
  late final Command0<AppUser?> pickFromGalleryCommand;

  // Câmera: a tela de captura devolve a foto e a tela chama este command.
  late final Command1<AppUser, ProfilePhoto> savePhotoCommand;

  // true enquanto qualquer uma das duas origens estiver processando.
  // Usado para bloquear o avatar e mostrar o carregamento.
  late final Computed<bool> isBusy = computed(
    () =>
        pickFromGalleryCommand.state.value.isRunning ||
        savePhotoCommand.state.value.isRunning,
  );

  Future<Result<AppUser?>> _pickFromGallery() async {
    final ProfilePhoto? photo;
    switch (await _picker.pickFromGallery()) {
      case ResultFailure(:final failure):
        return Result.failure(failure);
      case Success(:final value):
        photo = value;
    }

    // Usuário fechou a galeria sem escolher: não é erro, só não faz nada.
    if (photo == null) return const Result.success(null);

    return _updatePhoto(photo);
  }

  Future<Result<AppUser>> _savePhoto(ProfilePhoto photo) => _updatePhoto(photo);

  // Caminho comum das duas origens.
  Future<Result<AppUser>> _updatePhoto(ProfilePhoto photo) async {
    final result = await _facade.updateProfilePhoto(photo);

    result.when(
      onSuccess: (user) => _currentUser.value = user,
      onFailure: (_) {},
    );

    return result;
  }

  void dispose() {
    isBusy.dispose();
  }
}