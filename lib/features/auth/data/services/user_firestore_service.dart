import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/firebase/firestore_collections.dart';
import '../../../../core/result/result.dart';
import '../models/app_user_model.dart';
import 'user_remote_service.dart';

class UserFirestoreService implements UserRemoteService {
  final FirebaseFirestore _firestore;

  UserFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  @override
  Future<Result<void>> saveUser(AppUserModel user) async {
    try {
      // O uid do Firebase Auth é o id do documento: um documento por conta.
      // merge: true atualiza nome/foto sem apagar campos que existam depois.
      await _users
          .doc(user.uid)
          .set(user.toFirestore(), SetOptions(merge: true));
      return const Result.success(null);
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure('Não foi possível salvar os dados do usuário', exception: e),
      );
    }
  }
}