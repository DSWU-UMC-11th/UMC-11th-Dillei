import 'package:flutter/foundation.dart';

import '../core/session/session_guard.dart';
import '../core/utils/map_bounded.dart';
import '../core/utils/safe_notify.dart';
import '../data/models/favorite_list_item.dart';
import '../data/services/favorite_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import 'load_phase.dart';

class FavoritesViewModel extends ChangeNotifier with SafeNotify {
  FavoritesViewModel({
    required this.favoriteApi,
    required this.tmdbApi,
    required this.sessionGuard,
    required this.accountId,
    this.enrichmentConcurrency = 5,
  });

  final FavoriteApiService favoriteApi;
  final TmdbMovieService tmdbApi;
  final SessionGuard sessionGuard;
  final String accountId;
  final int enrichmentConcurrency;

  LoadPhase phase = LoadPhase.idle;
  List<FavoriteListItem> items = const [];
  String? errorMessage;
  int _refreshGeneration = 0;

  bool _stale(int sessionGen, int refreshGen) =>
      !sessionGuard.isCurrent(sessionGen, accountId) ||
      refreshGen != _refreshGeneration ||
      isDisposed;

  Future<void> refresh() async {
    final sessionGen = sessionGuard.generation;
    if (!sessionGuard.isCurrent(sessionGen, accountId) || isDisposed) return;
    final refreshGen = ++_refreshGeneration;

    phase = LoadPhase.loading;
    errorMessage = null;
    notifyIfAlive();
    try {
      final favorites = await favoriteApi.fetchMyFavorites();
      if (_stale(sessionGen, refreshGen)) return;

      // 한 번에 최대 5개씩 TMDB 상세를 조회하고, 1건 실패는 그 카드만 실패 처리
      final enriched = await mapBounded(favorites, enrichmentConcurrency, (
        favorite,
      ) async {
        try {
          final movie = await tmdbApi.fetchMovieDetails(favorite.movieId);
          return FavoriteListItem(favorite: favorite, movie: movie);
        } catch (_) {
          return FavoriteListItem(
            favorite: favorite,
            errorMessage: '영화 정보를 불러오지 못했습니다.',
          );
        }
      });
      if (_stale(sessionGen, refreshGen)) return;

      items = enriched;
      phase = items.isEmpty ? LoadPhase.empty : LoadPhase.ready;
    } catch (_) {
      if (_stale(sessionGen, refreshGen)) return;
      phase = LoadPhase.error;
      errorMessage = '내 즐겨찾기 목록을 불러오지 못했습니다.';
    } finally {
      if (!_stale(sessionGen, refreshGen)) notifyIfAlive();
    }
  }
}