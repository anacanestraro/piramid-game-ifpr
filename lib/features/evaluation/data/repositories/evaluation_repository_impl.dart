import '../../../../core/result/result.dart';
import '../../domain/entities/evaluation.dart';
import '../../domain/repositories/evaluation_repository.dart';
import '../models/evaluation_model.dart';
import '../services/evaluation_remote_service.dart';

class EvaluationRepositoryImpl implements EvaluationRepository {
  final EvaluationRemoteService _service;

  EvaluationRepositoryImpl(this._service);

  @override
  Future<Result<Evaluation?>> getById(String id) {
    return _service.getById(id);
  }

  @override
  Future<Result<List<Evaluation>>> getByEvaluator(String evaluatorUid) {
    return _service.getByEvaluator(evaluatorUid);
  }

  @override
  Future<Result<List<Evaluation>>> getAll() {
    return _service.getAll();
  }

  @override
  Future<Result<void>> save(Evaluation evaluation) {
    return _service.save(EvaluationModel.fromEntity(evaluation));
  }

  @override
  Future<Result<void>> deleteByPerson(String personId) {
    return _service.deleteByPerson(personId);
  }
}