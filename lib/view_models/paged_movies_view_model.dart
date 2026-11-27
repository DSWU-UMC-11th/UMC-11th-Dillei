import 'package:flutter/foundation.dart';

import '../core/utils/safe_notify.dart';
import '../data/models/tmdb_genre_dto.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/models/tmdb_movie_page.dart';
import '../data/services/tmdb_movie_service.dart';
import 'load_phase.dart';

class PagedMoviesViewModel extends ChangeNotifier with SafeNotify {
  PagedMoviesViewModel({required this.tmdbApi});

  final TmdbMovieService tmdbApi;

  static const maxTmdbPage = 500;

  LoadPhase phase = LoadPhase.idle;
  final List<TmdbMovieDto> movies = [];
  List<TmdbGenreDto> genres = const [];
  int nextPage = 1;
  int totalPages = 1;
  bool isLoadingMore = false;
  String? errorMessage;
  String? loadMoreError;
  int _requestGeneration = 0;
  ({int? genreId, String query}) _condition = (genreId: null, query: '');

  bool get hasMore => nextPage <= totalPages;
  int? get selectedGenreId => _condition.genreId;

  // 장르 칩에 쓸 장르 목록을 한 번만 가져옵니다. 실패해도 영화 목록은 계속 동작합니다.
  Future<void> loadGenres() async {
    if (isDisposed || genres.isNotEmpty) return;
    try {
      final result = await tmdbApi.fetchGenres();
      if (isDisposed) return;
      genres = result;
      notifyIfAlive();
    } catch (_) {
      // 장르 칩만 '전체'로 보일 뿐 목록 조회에는 영향이 없습니다.
    }
  }

  // 장르 칩을 눌렀을 때: 첫 page부터 다시 불러옵니다.
  Future<void> selectGenre(int? genreId) => loadInitial(genreId: genreId);

  // 장르/검색어/새로고침: 모든 상태를 비우고 첫 page부터 다시 요청합니다.
  Future<void> loadInitial({int? genreId, String query = ''}) async {
    if (isDisposed) return;
    _condition = (genreId: genreId, query: query.trim());
    final generation = ++_requestGeneration;

    phase = LoadPhase.loading;
    errorMessage = null;
    loadMoreError = null;
    isLoadingMore = false;
    movies.clear();
    nextPage = 1;
    totalPages = 1;
    notifyIfAlive();

    try {
      final page = await _fetchPage(1, _condition);
      if (generation != _requestGeneration || isDisposed) return;
      _applyFirstPage(page);
    } catch (_) {
      if (generation != _requestGeneration || isDisposed) return;
      phase = LoadPhase.error;
      errorMessage = _condition.query.isEmpty
          ? '영화 목록을 불러오지 못했습니다.'
          : '검색 결과를 불러오지 못했습니다.';
    } finally {
      if (generation == _requestGeneration && !isDisposed) notifyIfAlive();
    }
  }

  // 실패해도 nextPage를 올리지 않아 같은 page를 다시 요청할 수 있습니다.
  Future<void> loadNextPage() async {
    if (isDisposed || isLoadingMore || !hasMore || phase != LoadPhase.ready) {
      return;
    }
    final generation = _requestGeneration;
    final pageToLoad = nextPage;

    isLoadingMore = true;
    loadMoreError = null;
    notifyIfAlive();

    try {
      final page = await _fetchPage(pageToLoad, _condition);
      if (generation != _requestGeneration || isDisposed) return;
      _appendPage(page);
    } catch (_) {
      if (generation != _requestGeneration || isDisposed) return;
      loadMoreError = '다음 페이지를 불러오지 못했습니다. 같은 페이지를 다시 요청합니다.';
    } finally {
      if (generation == _requestGeneration && !isDisposed) {
        isLoadingMore = false;
        notifyIfAlive();
      }
    }
  }

  Future<TmdbMoviePage> _fetchPage(
    int page,
    ({int? genreId, String query}) condition,
  ) async {
    final result = condition.query.isNotEmpty
        ? await tmdbApi.searchMovies(page: page, query: condition.query)
        : await tmdbApi.discoverMovies(page: page, genreId: condition.genreId);
    if (_pageNumber(result) != page || _totalPagesOf(result) < 0) {
      throw const FormatException('TMDB page metadata is inconsistent.');
    }
    return result;
  }

  void _applyFirstPage(TmdbMoviePage page) {
    movies
      ..clear()
      ..addAll(_dedupe(_moviesOf(page)));
    totalPages = _totalPagesOf(page) > maxTmdbPage
        ? maxTmdbPage
        : _totalPagesOf(page);
    nextPage = _pageNumber(page) + 1;
    phase = movies.isEmpty ? LoadPhase.empty : LoadPhase.ready;
  }

  void _appendPage(TmdbMoviePage page) {
    movies.addAll(_dedupe(_moviesOf(page)));
    totalPages = _totalPagesOf(page) > maxTmdbPage
        ? maxTmdbPage
        : _totalPagesOf(page);
    nextPage = _pageNumber(page) + 1;
  }

  List<TmdbMovieDto> _dedupe(List<TmdbMovieDto> incoming) {
    final seen = movies.map((movie) => movie.id).toSet();
    return incoming.where((movie) => seen.add(movie.id)).toList(growable: false);
  }

  // ⚠️ TmdbMoviePage의 필드 이름이 다르면 이 3줄만 고치세요.
  //    (tmdb_movie_page.dart를 열어 실제 이름을 확인합니다.)
  int _pageNumber(TmdbMoviePage p) => p.page;
  int _totalPagesOf(TmdbMoviePage p) => p.totalPages;
  List<TmdbMovieDto> _moviesOf(TmdbMoviePage p) => p.results;
}