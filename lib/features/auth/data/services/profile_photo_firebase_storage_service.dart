import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/result/result.dart';
import 'profile_photo_storage_service.dart';

// Fotos ficam em: users/{uid}/avatar_{timestamp}
// Observação: o Firebase Storage exige o plano Blaze. Sem ele, o upload
// falha e o usuário recebe a mensagem amigável de _mapError.
class ProfilePhotoFirebaseStorageService implements ProfilePhotoStorageService {
  static const _usersFolder = 'users';
  static const _filePrefix = 'avatar_';

  // Por quanto tempo o SDK pode repetir uma operação que falhou.
  // O padrão do Firebase é de vários minutos (10 min para upload),
  // o que deixa a tela "carregando" sem resposta quando o Storage
  // não está disponível.
  static const _maxRetryTime = Duration(seconds: 15);

  // Limite total de espera de cada etapa, como garantia extra.
  static const _timeout = Duration(seconds: 20);

  static const _unavailableMessage = 'Não foi possível enviar a foto. '
      'Verifique se o Firebase Storage está ativado.';

  final FirebaseStorage _storage;

  ProfilePhotoFirebaseStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance {
    _storage.setMaxUploadRetryTime(_maxRetryTime);
    _storage.setMaxOperationRetryTime(_maxRetryTime);
  }

  Reference _userFolder(String uid) => _storage.ref('$_usersFolder/$uid');

  @override
  Future<Result<String>> upload({
    required String uid,
    required Uint8List bytes,
    required String contentType,
  }) async {
    try {
      // Nome único a cada envio: se sobrescrevesse sempre o mesmo arquivo,
      // a URL continuaria igual e a imagem antiga ficaria em cache na tela.
      final fileName = '$_filePrefix${DateTime.now().millisecondsSinceEpoch}';
      final reference = _userFolder(uid).child(fileName);

      await _sendFile(reference, bytes, contentType);

      final url = await reference.getDownloadURL().timeout(_timeout);

      await _deleteOldPhotos(uid, keep: fileName);

      return Result.success(url);
    } on FirebaseException catch (e) {
      return Result.failure(_mapError(e));
    } on TimeoutException catch (e) {
      return Result.failure(
        Failure(
          'O envio da foto demorou demais. '
          'Verifique se o Firebase Storage está ativado.',
          exception: e,
        ),
      );
    } catch (e) {
      return Result.failure(Failure(_unavailableMessage, exception: e));
    }
  }

  // Envia o arquivo respeitando o tempo limite. Se estourar,
  // cancela o envio para ele não continuar rodando em segundo plano.
  Future<void> _sendFile(
    Reference reference,
    Uint8List bytes,
    String contentType,
  ) async {
    final task = reference.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );

    try {
      await task.timeout(_timeout);
    } on TimeoutException {
      await task.cancel();
      rethrow;
    }
  }

  // Remove as fotos anteriores do usuário para não acumular arquivos.
  // É "melhor esforço": se falhar, a foto nova já foi salva e o
  // perfil continua correto, então o erro é ignorado.
  Future<void> _deleteOldPhotos(String uid, {required String keep}) async {
    try {
      final listing = await _userFolder(uid).listAll().timeout(_timeout);
      final oldPhotos = listing.items.where((item) => item.name != keep);
      await Future.wait(oldPhotos.map((item) => item.delete()));
    } on FirebaseException {
      // Ignorado de propósito (ver comentário acima).
    } on TimeoutException {
      // Idem.
    }
  }

  // Traduz os códigos de erro do Storage para mensagens amigáveis.
  // Fica aqui (e não no core) porque só este service usa o Storage.
  Failure _mapError(FirebaseException e) {
    final message = switch (e.code) {
      'unauthenticated' => 'Você precisa estar logado para trocar a foto.',
      'unauthorized' => 'Você não tem permissão para trocar esta foto.',
      'retry-limit-exceeded' =>
        'O servidor de fotos não respondeu. '
            'Verifique se o Firebase Storage está ativado.',
      'quota-exceeded' => 'Limite de armazenamento atingido.',
      'bucket-not-found' ||
      'project-not-found' =>
        'O armazenamento de fotos (Firebase Storage) não está ativado.',
      _ => _unavailableMessage,
    };

    return Failure(message, exception: e);
  }
}