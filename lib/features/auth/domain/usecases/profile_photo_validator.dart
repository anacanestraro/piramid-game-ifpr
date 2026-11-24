import '../../../../core/result/result.dart';
import '../entities/profile_photo.dart';

// Regras da foto de perfil. Os mesmos limites estão no storage.rules:
// o app avisa antes de enviar e o servidor garante de verdade.
// Retorna null se válida, ou uma Failure descrevendo o problema.
class ProfilePhotoValidator {
  static const maxSizeInMegabytes = 5;
  static const maxSizeInBytes = maxSizeInMegabytes * 1024 * 1024;

  static const allowedContentTypes = {
    'image/jpeg',
    'image/png',
    'image/webp',
  };

  Failure? validate(ProfilePhoto photo) {
    if (photo.bytes.isEmpty) {
      return const Failure('A imagem selecionada está vazia.');
    }

    if (!allowedContentTypes.contains(photo.contentType)) {
      return const Failure('Formato não suportado. Use JPG, PNG ou WebP.');
    }

    if (photo.sizeInBytes > maxSizeInBytes) {
      return const Failure(
        'A imagem deve ter no máximo $maxSizeInMegabytes MB.',
      );
    }

    return null;
  }
}