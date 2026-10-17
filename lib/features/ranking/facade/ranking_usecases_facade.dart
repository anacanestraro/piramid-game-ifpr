import '../../../core/result/result.dart';
import '../domain/entities/ranking_entry.dart';
import '../domain/usecases/calculate_global_ranking_usecase.dart';
import '../domain/usecases/calculate_personal_ranking_usecase.dart';

// Agrupa os use cases de ranking (seção 4.4 da especificação).
class RankingUseCasesFacade {
  final CalculatePersonalRankingUseCase _personal;
  final CalculateGlobalRankingUseCase _global;

  RankingUseCasesFacade({
    required this._personal,
    required this._global,
  });

  Future<Result<List<RankingEntry>>> personalRanking() => _personal();

  Future<Result<List<RankingEntry>>> globalRanking() => _global();
}