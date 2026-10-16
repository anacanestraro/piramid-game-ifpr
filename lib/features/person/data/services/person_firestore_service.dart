import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_collections.dart';
import '../../../../core/firebase/firestore_error_mapper.dart';
import '../../../../core/result/result.dart';
import '../models/person_model.dart';
import 'person_remote_service.dart';

class PersonFirestoreService implements PersonRemoteService {
  final FirebaseFirestore _firestore;

  PersonFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _people =>
      _firestore.collection(FirestoreCollections.people);

  @override
  Future<Result<List<PersonModel>>> getAll() {
    return _guard('Não foi possível carregar as pessoas.', () async {
      final snapshot = await _people.orderBy('name').get();
      return snapshot.docs
          .map((doc) => PersonModel.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Future<Result<PersonModel?>> getById(String id) {
    return _guard('Não foi possível carregar a pessoa.', () async {
      final doc = await _people.doc(id).get();
      final data = doc.data();

      if (!doc.exists || data == null) return null;

      return PersonModel.fromFirestore(doc.id, data);
    });
  }

  @override
  Future<Result<PersonModel?>> findByLinkedUser(String uid) {
    return _guard('Não foi possível verificar o vínculo da conta.', () async {
      final snapshot = await _people
          .where('linkedUserUid', isEqualTo: uid)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return PersonModel.fromFirestore(doc.id, doc.data());
    });
  }

  @override
  Future<Result<String>> create(PersonModel person) {
    return _guard('Não foi possível cadastrar a pessoa.', () async {
      // add() cria o documento com um id único gerado pelo Firestore.
      final reference = await _people.add(person.toFirestore());
      return reference.id;
    });
  }

  @override
  Future<Result<void>> update(PersonModel person) {
    return _guard('Não foi possível alterar a pessoa.', () async {
      // update() falha com "not-found" se o documento não existir,
      // em vez de criar um novo sem querer (como o set() faria).
      await _people.doc(person.id).update(person.toFirestore());
    });
  }

  @override
  Future<Result<void>> delete(String id) {
    return _guard('Não foi possível remover a pessoa.', () async {
      await _people.doc(id).delete();
    });
  }

  // Executa a operação e padroniza o tratamento de erro,
  // evitando repetir o mesmo try/catch em todos os métodos.
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
    } on PersonModelParseException catch (e) {
      return Result.failure(
        Failure('Há um registro de pessoa com dados inválidos.', exception: e),
      );
    }
  }
}