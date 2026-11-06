import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';

enum MyRatingsLoadStatus {
  idle,
  loading,
  success,
  empty,
  error,
}

class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(
    this._service,
    this._movieService,
    this.memberId,
  );

  final RatingApiService _service;
  final TmdbMovieService _movieService;
  final int memberId;

  final Map<int, TmdbMovieDto?> _movieCache = {};

  int _requestVersion = 0;
  bool _disposed = false;

  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.idle;
  String? message;

  // 저장은 성공했지만 목록 재조회가 실패했을 때의 안내
  String? refreshWarning;

  // Challenge: 다중 선택/삭제
  final Set<int> selectedRatingIds = {};
  bool isEditMode = false;
  bool isDeletingSelected = false;

  bool get hasSelection => selectedRatingIds.isNotEmpty;

  bool get isAllSelected =>
      ratings.isNotEmpty &&
      ratings.every(
        (item) => selectedRatingIds.contains(item.rating.ratingId),
      );

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  /// [showLoading]이 false면 기존 목록을 유지한 채 조용히 다시 읽습니다.
  /// (수정/삭제 직후 재조회에 사용 → 화면이 깜빡이지 않고 Dialog context도 유지됨)
  Future<void> load({bool showLoading = true}) async {
    final version = ++_requestVersion;

    message = null;
    refreshWarning = null;
    if (showLoading) {
      status = MyRatingsLoadStatus.loading;
      _notify();
    }

    try {
      final rawRatings = await _service.fetchMyRatings(memberId);

      if (_disposed || version != _requestVersion) return;

      final entries = <RatingWithMovie>[];
      var missingMovies = 0;

      for (final rating in rawRatings) {
        if (_disposed || version != _requestVersion) return;

        if (!_movieCache.containsKey(rating.movieId)) {
          try {
            _movieCache[rating.movieId] =
                await _movieService.findMovieById(rating.movieId);
          } on DioException {
            // 영화 정보 조회 실패 → 대체 화면 사용
          }
        }

        final movie = _movieCache[rating.movieId];
        if (movie == null) missingMovies++;

        entries.add(RatingWithMovie(rating: rating, movie: movie));
      }

      if (_disposed || version != _requestVersion) return;

      ratings = entries;

      // 서버에 남아 있는 항목만 선택 상태 유지 (삭제 실패 항목의 선택 유지용)
      final ids = entries.map((e) => e.rating.ratingId).toSet();
      selectedRatingIds.retainWhere(ids.contains);

      status = entries.isEmpty
          ? MyRatingsLoadStatus.empty
          : MyRatingsLoadStatus.success;

      if (missingMovies > 0) {
        message = '일부 영화 정보를 가져오지 못해 대체 화면을 표시합니다.';
      }
    } on DioException catch (error) {
      if (_disposed || version != _requestVersion) return;
      status = MyRatingsLoadStatus.error;
      message = writeErrorMessage(error);
    } catch (_) {
      if (_disposed || version != _requestVersion) return;
      status = MyRatingsLoadStatus.error;
      message = '평점을 불러오지 못했습니다.';
    }

    _notify();
  }

  // 쓰기 성공 뒤 재조회. GET 실패는 "저장 실패"가 아니라 별도 경고로 표시합니다.
  Future<void> _refreshAfterWrite() async {
    await load(showLoading: false);
    if (status == MyRatingsLoadStatus.error) {
      refreshWarning = '저장은 완료됐지만 목록을 불러오지 못했습니다. 조회만 다시 시도해 주세요.';
      _notify();
    }
  }

  // ───────── 선택 ─────────

  void toggleSelection(int ratingId) {
    if (selectedRatingIds.contains(ratingId)) {
      selectedRatingIds.remove(ratingId);
    } else {
      selectedRatingIds.add(ratingId);
    }
    _notify();
  }

  void selectAll() {
    if (isAllSelected) {
      selectedRatingIds.clear();
    } else {
      selectedRatingIds
        ..clear()
        ..addAll(ratings.map((item) => item.rating.ratingId));
    }
    _notify();
  }

  void enterEditMode() {
    isEditMode = true;
    selectedRatingIds.clear();
    _notify();
  }

  void exitEditMode() {
    isEditMode = false;
    selectedRatingIds.clear();
    _notify();
  }

  // ───────── 수정 / 삭제 ─────────

  /// 쓰기 실패 시 DioException을 rethrow → Dialog가 실패로 처리합니다.
  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    try {
      await _service.updateRating(
        memberId: memberId,
        ratingId: ratingId,
        score: score,
        comment: comment,
      );
      // TEMP(인증용): 저장 성공 후 GET만 실패시키려면 아래 줄의 주석을 풀고, 인증 후 다시 지우세요.
      // RatingApiService.debugFailNextFetch = true;
    } on DioException catch (error) {
      message = writeErrorMessage(error);
      _notify();
      if (shouldRefreshAfterRatingError(error)) {
        await load(showLoading: false);
      }
      rethrow;
    }
    await _refreshAfterWrite();
  }

  Future<void> deleteRating(int ratingId) async {
    try {
      await _service.deleteRating(memberId: memberId, ratingId: ratingId);
    } on DioException catch (error) {
      message = writeErrorMessage(error);
      _notify();
      if (shouldRefreshAfterRatingError(error)) {
        await load(showLoading: false);
      }
      rethrow;
    }
    await _refreshAfterWrite();
  }

  /// 선택 항목 다중 삭제. 삭제에 실패한 개수를 반환합니다.
  Future<int> deleteSelectedRatings() async {
    if (isDeletingSelected || selectedRatingIds.isEmpty) return 0;

    isDeletingSelected = true;
    _notify();

    var failed = 0;
    try {
      for (final ratingId in selectedRatingIds.toList()) {
        // 원본 Set이 아니라 복사본을 순회
        try {
          // TEMP(인증용): 일부 실패 재현 → 아래 줄 주석을 풀고, 인증 후 다시 지우세요.
          // if (ratingId == selectedRatingIds.first) {
          //   throw DioException(requestOptions: RequestOptions(path: '/debug'));
          // }
          await _service.deleteRating(memberId: memberId, ratingId: ratingId);
          selectedRatingIds.remove(ratingId); // 성공한 항목만 선택에서 제거
        } on DioException {
          failed++; // 실패한 항목은 선택 상태 유지
        }
      }
    } finally {
      isDeletingSelected = false;
      _notify();
    }

    await _refreshAfterWrite();

    if (failed == 0) {
      exitEditMode();
    }
    return failed;
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    super.dispose();
  }
}