import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// ⚠️ apiErrorCode가 있는 8주차 파일 경로로 바꾸세요.
import '../core/network/api_error.dart';
import '../core/session/session_guard.dart';
import '../core/utils/safe_notify.dart';
import '../data/services/favorite_api_service.dart';

class FavoriteDetailViewModel extends ChangeNotifier with SafeNotify {
  FavoriteDetailViewModel({
    required this.movieId,
    required this.favoriteApi,
    required this.sessionGuard,
    required this.accountId,
  });

  final int movieId;
  final FavoriteApiService favoriteApi;
  final SessionGuard sessionGuard;
  final String accountId;

  bool isFavorite = false;
  bool hasLoadedStatus = false;
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;

  // 이 요청을 보낸 시점의 세션이 지금도 유효한지 확인합니다.
  bool _stale(int generation) =>
      !sessionGuard.isCurrent(generation, accountId) || isDisposed;

  Future<void> load() async {
    if (isLoading || isSaving) return;
    final generation = sessionGuard.generation;
    if (_stale(generation)) return;
    isLoading = true;
    errorMessage = null;
    notifyIfAlive();
    try {
      final result = await favoriteApi.checkFavorite(movieId: movieId);
      if (_stale(generation)) return;
      isFavorite = result.isFavorite;
      hasLoadedStatus = true;
    } catch (_) {
      if (_stale(generation)) return;
      errorMessage = '즐겨찾기 여부를 확인하지 못했습니다.';
    } finally {
      if (!_stale(generation)) {
        isLoading = false;
        notifyIfAlive();
      }
    }
  }

  // 서버 성공을 확인한 뒤에만 북마크를 바꿉니다(optimistic update 없음).
  Future<void> toggle() async {
    if (isSaving || isLoading || !hasLoadedStatus) return;
    final generation = sessionGuard.generation;
    if (_stale(generation)) return;
    final before = isFavorite;
    isSaving = true;
    errorMessage = null;
    notifyIfAlive();
    try {
      if (before) {
        await favoriteApi.deleteFavorite(movieId: movieId);
        if (_stale(generation)) return;
        isFavorite = false;
      } else {
        await favoriteApi.addFavorite(movieId: movieId);
        if (_stale(generation)) return;
        isFavorite = true;
      }
    } on DioException catch (error) {
      if (_stale(generation)) return;
      final code = apiErrorCode(error);
      if (code == 'FAVORITE409_1' || code == 'FAVORITE404_1') {
        // POST/DELETE를 반복하지 않고 서버의 현재 값으로 맞춥니다.
        try {
          final synced = await favoriteApi.checkFavorite(movieId: movieId);
          if (_stale(generation)) return;
          isFavorite = synced.isFavorite;
          errorMessage = null;
        } catch (_) {
          if (_stale(generation)) return;
          isFavorite = before;
          errorMessage = '서버 상태를 다시 확인하지 못했습니다.';
        }
      } else {
        isFavorite = before;
        errorMessage = before ? '즐겨찾기 해제에 실패했습니다.' : '즐겨찾기 등록에 실패했습니다.';
      }
    } catch (_) {
      if (_stale(generation)) return;
      isFavorite = before;
      errorMessage = before ? '즐겨찾기 해제에 실패했습니다.' : '즐겨찾기 등록에 실패했습니다.';
    } finally {
      if (!_stale(generation)) {
        isSaving = false;
        notifyIfAlive();
      }
    }
  }
}