import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_collections.dart';
import '../../../../core/firebase/firestore_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../models/evaluation_model.dart';
import 'evaluation_remote_service.dart';

class EvaluationFirestoreService implements EvaluationRemoteService {
  // Limite de operações por lote de escrita no Firestore.
  static const _maxBatchSize = 500;

  final FirebaseFirestore _firestore;

  EvaluationFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _evaluations =>
      _firestore.collection(FirestoreCollections.evaluations);

  @override
  Future<Result<EvaluationModel?>> getById(String id) {
    return _guard('Não foi possível carregar a avaliação.', () async {
      final doc = await _evaluations.doc(id).get();
      final data = doc.data();

      if (!doc.exists || data == null) return null;

      return EvaluationModel.fromFirestore(doc.id, data);
    });
  }

  @override
  Future<Result<List<EvaluationModel>>> getByEvaluator(String evaluatorUid) {
    return _guard('Não foi possível carregar suas avaliações.', () async {
      final snapshot = await _evaluations
          .where('evaluatorUid', isEqualTo: evaluatorUid)
          .get();
      return _toModels(snapshot);
    });
  }

  @override
  Future<Result<List<EvaluationModel>>> getAll() {
    return _guard('Não foi possível carregar as avaliações.', () async {
      final snapshot = await _evaluations.get();
      return _toModels(snapshot);
    });
  }

  @override
  Future<Result<void>> save(EvaluationModel evaluation) {
    return _guard('Não foi possível salvar a avaliação.', () async {
      // set() no id determinístico: cria na primeira vez,
      // sobrescreve nas seguintes. Nunca gera duplicata.
      await _evaluations.doc(evaluation.id).set(evaluation.toFirestore());
    });
  }

  @override
  Future<Result<void>> deleteByPerson(String personId) {
    return _guard('Não foi possível remover as avaliações.', () async {
      final snapshot =
          await _evaluations.where('personId', isEqualTo: personId).get();

      // Remove em lotes: cada batch é aplicado de uma vez só.
      final docs = snapshot.docs;
      for (var start = 0; start < docs.length; start += _maxBatchSize) {
        final batch = _firestore.batch();
        final end = (start + _maxBatchSize).clamp(0, docs.length);
        for (final doc in docs.sublist(start, end)) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    });
  }

  List<EvaluationModel> _toModels(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => EvaluationModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  // Executa a operação e padroniza o tratamento de erro.
  Future<Result<T>> _guard<T>(
    String fallbackMessage,
    Future<T> Function() action,
  ) async {
    try {
      return Result.success(await action());
    } on FirebaseException catch (e) {
      return Result.failure(
        FirestoreErrorMapper.fromException(e, fallback: fallbackMessage),
      );
    } on EvaluationModelParseException catch (e) {
      return Result.failure(
        Failure('Há uma avaliação com dados inválidos.', exception: e),
      );
    }
  }
}