import 'dart:typed_data';
import '../../../../core/result/result.dart';

// Armazena a foto de perfil do usuário em um serviço de arquivos remoto.
// O repository depende só deste contrato: trocar o Firebase Storage por
// outro serviço não exige mudar nenhuma outra camada.
abstract class ProfilePhotoStorageService {
  // Envia a imagem e retorna a URL pública de download.
  // Recebe bytes (e não um File) para funcionar igual na web e no celular.
  Future<Result<String>> upload({
    required String uid,
    required Uint8List bytes,
    required String contentType,
  });
}