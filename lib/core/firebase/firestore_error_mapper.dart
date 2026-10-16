import 'package:cloud_firestore/cloud_firestore.dart';
import '../result/result.dart';

// Traduz erros do Firestore para mensagens amigáveis.
// Fica no core porque pessoas e avaliações usam o mesmo tratamento.
class FirestoreErrorMapper {
  FirestoreErrorMapper._();

  static Failure fromException(
    FirebaseException e, {
    required String fallback,
  }) {
    final message = switch (e.code) {
      'permission-denied' => 'Você não tem permissão para esta operação.',
      'unavailable' => 'Sem conexão com o servidor. Tente novamente.',
      'not-found' => 'Registro não encontrado.',
      _ => fallback,
    };

    return Failure(message, exception: e);
  }
}