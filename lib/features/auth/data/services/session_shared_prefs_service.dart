import 'dart:convert';
import '../../../../core/result/result.dart';
import '../../../../core/storage/local_storage_helper.dart';
import '../models/app_user_model.dart';
import 'session_cache_service.dart';

class SessionSharedPrefsService implements SessionCacheService {
  static const _storageKey = 'session_user';

  final LocalStorageHelper _storage;

  SessionSharedPrefsService(this._storage);

  @override
  Future<Result<AppUserModel?>> getUser() async {
    final result = await _storage.getString(_storageKey);

    return result.when(
      onSuccess: (jsonString) {
        if (jsonString == null) return const Result.success(null);

        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          return Result.success(AppUserModel.fromCacheJson(json));
        } catch (_) {
          // Cache ilegível vale como "sem cache", nunca como erro.
          return const Result.success(null);
        }
      },
      onFailure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<void>> saveUser(AppUserModel user) {
    return _storage.setString(_storageKey, jsonEncode(user.toCacheJson()));
  }

  @override
  Future<Result<void>> clear() {
    return _storage.remove(_storageKey);
  }
}