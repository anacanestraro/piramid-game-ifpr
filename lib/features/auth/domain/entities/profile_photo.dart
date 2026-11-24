import 'dart:typed_data';

// Imagem escolhida pelo usuário para a foto de perfil.
// Não importa de onde veio (galeria ou câmera): para o domínio,
// uma foto é só o conteúdo e o tipo do arquivo.
class ProfilePhoto {
  final Uint8List bytes;

  // Tipo MIME, ex.: "image/jpeg".
  final String contentType;

  const ProfilePhoto({required this.bytes, required this.contentType});

  int get sizeInBytes => bytes.lengthInBytes;
}