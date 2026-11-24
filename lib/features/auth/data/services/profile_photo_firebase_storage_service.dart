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

  final FirebaseStorage _storage;

  ProfilePhotoFirebaseStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

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

      await reference.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );

      final url = await reference.getDownloadURL();

      await _deleteOldPhotos(uid, keep: fileName);

      return Result.success(url);
    } on FirebaseException catch (e) {
      return Result.failure(_mapError(e));
    } catch (e) {
      return Result.failure(
        Failure(
          'Não foi possível enviar a foto. '
          'Verifique se o Firebase Storage está ativado.',
          exception: e,
        ),
      );
    }
  }

  // Remove as fotos anteriores do usuário para não acumular arquivos.
  // É "melhor esforço": se falhar, a foto nova já foi salva e o
  // perfil continua correto, então o erro é ignorado.
  Future<void> _deleteOldPhotos(String uid, {required String keep}) async {
    try {
      final listing = await _userFolder(uid).listAll();
      final oldPhotos = listing.items.where((item) => item.name != keep);
      await Future.wait(oldPhotos.map((item) => item.delete()));
    } on FirebaseException {
      // Ignorado de propósito (ver comentário acima).
    }
  }

  // Traduz os códigos de erro do Storage para mensagens amigáveis.
  // Fica aqui (e não no core) porque só este service usa o Storage.
  Failure _mapError(FirebaseException e) {
    final message = switch (e.code) {
      'unauthenticated' => 'Você precisa estar logado para trocar a foto.',
      'unauthorized' => 'Você não tem permissão para trocar esta foto.',
      'retry-limit-exceeded' => 'Sem conexão com o servidor. Tente novamente.',
      'quota-exceeded' => 'Limite de armazenamento atingido.',
      'bucket-not-found' ||
      'project-not-found' =>
        'O armazenamento de fotos (Firebase Storage) não está ativado.',
      _ => 'Não foi possível enviar a foto. '
          'Verifique se o Firebase Storage está ativado.',
    };

    return Failure(message, exception: e);
  }
}