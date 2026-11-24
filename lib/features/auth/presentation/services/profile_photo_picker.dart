import '../../../../core/result/result.dart';
import '../../domain/entities/profile_photo.dart';

// Abre a galeria do sistema para o usuário escolher uma imagem.
// Fica na apresentação porque é uma interação com o usuário
// (abre um diálogo do sistema), como um seletor de data.
abstract class ProfilePhotoPicker {
  // Retorna null quando o usuário fecha a galeria sem escolher.
  Future<Result<ProfilePhoto?>> pickFromGallery();
}