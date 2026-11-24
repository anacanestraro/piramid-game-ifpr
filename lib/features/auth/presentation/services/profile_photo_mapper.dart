import 'package:image_picker/image_picker.dart';
import '../../domain/entities/profile_photo.dart';

// Converte o arquivo devolvido pela galeria (image_picker) ou pela
// câmera (camera) em ProfilePhoto. Os dois pacotes usam o mesmo tipo
// XFile, então uma única conversão atende as duas origens.
class ProfilePhotoMapper {
  ProfilePhotoMapper._();

  static const _contentTypesByExtension = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  };

  // Tipo usado quando não dá para descobrir o formato.
  // O ProfilePhotoValidator rejeita esse tipo com uma mensagem clara.
  static const _unknownContentType = 'application/octet-stream';

  static Future<ProfilePhoto> fromXFile(
    XFile file, {
    String? fallbackContentType,
  }) async {
    final bytes = await file.readAsBytes();

    return ProfilePhoto(
      bytes: bytes,
      contentType: _contentTypeOf(file) ??
          fallbackContentType ??
          _unknownContentType,
    );
  }

  // Na web o XFile normalmente informa o mimeType; no celular nem
  // sempre, então cai para a extensão do nome do arquivo.
  static String? _contentTypeOf(XFile file) {
    final mimeType = file.mimeType;
    if (mimeType != null && mimeType.isNotEmpty) return mimeType;

    final name = file.name.toLowerCase();
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1) return null;

    return _contentTypesByExtension[name.substring(dotIndex + 1)];
  }
}