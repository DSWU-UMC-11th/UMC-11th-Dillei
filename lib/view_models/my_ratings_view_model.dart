import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../data/models/rating_dto.dart';
import '../data/models/rating_with_movie.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import 'auth_view_model.dart';

// 화면 호환을 위해 enum은 그대로 둡니다. v7에서는 목록을 서버에서 읽지 않으므로
// 실제로는 empty ↔ success만 사용합니다.
enum MyRatingsLoadStatus {
  idle,
  loading,
  success,
  empty,
  error,
}

/// 이번 로그인 세션에서 등록한 평점을 보관하고, 수정·삭제합니다.
/// (v7에는 토큰 기반 "내 평점 전체 조회" API가 없습니다.)
class MyRatingsViewModel extends ChangeNotifier {
  MyRatingsViewModel(
    this._service,
    this._movieService,
    this._auth,
  ) : _seenSession = _auth.sessionVersion {
    _auth.addListener(_onAuthChanged);
  }

  final RatingApiService _service;
  final TmdbMovieService _movieService;
  final AuthViewModel _auth;

  final Map<int, TmdbMovieDto?> _movieCache = {};

  // 이번 로그인 세션에서 등록한 평점 (최신순)
  final List<RatingDto> _sessionRatings = [];

  int _seenSession;
  int _requestVersion = 0;
  bool _disposed = false;

  List<RatingWithMovie> ratings = const [];
  MyRatingsLoadStatus status = MyRatingsLoadStatus.empty;
  String? message;

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

  // 로그아웃·만료·계정 전환 뒤에는 요청을 보낸 세션이 아니므로 응답을 반영하지 않습니다.
  bool _isOldSession(int version) =>
      _disposed || version != _auth.sessionVersion;

  bool _isStale(int version) => _disposed || version != _requestVersion;

  // ───────── 세션이 바뀌면 이전 사용자의 데이터를 비웁니다 ─────────

  void _onAuthChanged() {
    final changed = _auth.sessionVersion != _seenSession;
    _seenSession = _auth.sessionVersion;
    if (!changed && _auth.status == AuthStatus.signedIn) return;
    _resetSessionData();
  }

  void _resetSessionData() {
    if (_sessionRatings.isEmpty &&
        ratings.isEmpty &&
        selectedRatingIds.isEmpty &&
        !isEditMode &&
        !isDeletingSelected &&
        message == null) {
      return;
    }
    _requestVersion++; // 진행 중이던 영화 정보 조회 결과도 버립니다.
    _sessionRatings.clear();
    ratings = const [];
    selectedRatingIds.clear();
    isEditMode = false;
    isDeletingSelected = false;
    status = MyRatingsLoadStatus.empty;
    message = null;
    _notify();
  }

  // ───────── 목록 ─────────

  /// 평점 등록 성공 직후 MovieDetailViewModel이 호출합니다.
  /// 등록 result의 Rating을 현재 세션 목록 맨 위에 추가합니다.
  void addCreated(RatingDto rating, {required int sessionVersion}) {
    if (_isOldSession(sessionVersion) || _auth.status != AuthStatus.signedIn) {
      return;
    }
    _sessionRatings.removeWhere((item) => item.ratingId == rating.ratingId);
    _sessionRatings.insert(0, rating);
    unawaited(load());
  }

  /// 세션 목록을 화면에 반영하고, 아직 모르는 영화 정보를 TMDB에서 가져옵니다.
  /// (서버의 평점 GET은 호출하지 않습니다.)
  Future<void> load() async {
    final version = ++_requestVersion;
    _publish(); // 캐시에 있는 정보로 먼저 표시

    for (final rating in List.of(_sessionRatings)) {
      if (_isStale(version)) return;
      if (_movieCache.containsKey(rating.movieId)) continue;
      try {
        _movieCache[rating.movieId] =
            await _movieService.findMovieById(rating.movieId);
      } on DioException {
        // 영화 정보 조회 실패 → 대체 화면("영화 #번호")을 사용합니다.
      }
    }

    if (_isStale(version)) return;
    _publish(checkMissing: true);
  }

  void _publish({bool checkMissing = false}) {
    ratings = [
      for (final rating in _sessionRatings)
        RatingWithMovie(rating: rating, movie: _movieCache[rating.movieId]),
    ];
    status = ratings.isEmpty
        ? MyRatingsLoadStatus.empty
        : MyRatingsLoadStatus.success;

    // 목록에 남아 있는 항목만 선택 상태를 유지합니다.
    selectedRatingIds.retainWhere(
      (id) => _sessionRatings.any((item) => item.ratingId == id),
    );

    message = checkMissing && ratings.any((item) => item.movie == null)
        ? '일부 영화 정보를 가져오지 못해 대체 화면을 표시합니다.'
        : null;
    _notify();
  }

  void _removeLocal(int ratingId) {
    _sessionRatings.removeWhere((item) => item.ratingId == ratingId);
    selectedRatingIds.remove(ratingId);
    _publish();
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

  // ───────── 수정 / 삭제 (v7: 토큰 기반, memberId 없음) ─────────

  /// 쓰기 실패 시 DioException을 rethrow → Dialog가 실패로 처리합니다.
  /// PATCH는 전체 교체이므로 score와 comment를 항상 함께 보냅니다.
  Future<void> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final version = _auth.sessionVersion;
    try {
      final updated = await _service.updateRating(
        ratingId: ratingId,
        score: score,
        comment: comment,
      );
      if (_isOldSession(version)) return; // 이전 세션의 늦은 응답은 반영하지 않습니다.

      final index = _sessionRatings.indexWhere(
        (item) => item.ratingId == updated.ratingId,
      );
      if (index >= 0) _sessionRatings[index] = updated;
      unawaited(load());
    } on DioException catch (error) {
      await _handleWriteError(error, version, ratingId: ratingId);
      rethrow;
    }
  }

  /// v7 삭제 성공은 result가 null인 200입니다. (파싱은 Service가 합니다.)
  Future<void> deleteRating(int ratingId) async {
    final version = _auth.sessionVersion;
    try {
      await _service.deleteRating(ratingId);
      if (_isOldSession(version)) return;
      _removeLocal(ratingId);
    } on DioException catch (error) {
      await _handleWriteError(error, version, ratingId: ratingId);
      rethrow;
    }
  }

  /// 선택 항목 다중 삭제.
  /// 삭제에 실패한 개수를 반환하고, 도중에 세션이 끝나면(401·로그아웃) null을 반환합니다.
  Future<int?> deleteSelectedRatings() async {
    if (isDeletingSelected || selectedRatingIds.isEmpty) return 0;

    final version = _auth.sessionVersion;
    isDeletingSelected = true;
    _notify();

    var failed = 0;
    try {
      // 원본 Set이 아니라 복사본을 순회
      for (final ratingId in selectedRatingIds.toList()) {
        if (_isOldSession(version)) return null;
        try {
          await _service.deleteRating(ratingId);
          if (_isOldSession(version)) return null;
          _removeLocal(ratingId); // 성공한 항목만 목록·선택에서 제거
        } on DioException catch (error) {
          final code = apiErrorCode(error);
          if (isAuthExpiredCode(code)) {
            // 401: 세션을 정리하면 Router가 /login으로 보냅니다.
            if (!_isOldSession(version)) await _auth.expireSession();
            return null;
          }
          if (code == 'RATING404_1') {
            // 이미 서버에 없는 평점이므로 목록에서만 제거합니다.
            if (!_isOldSession(version)) _removeLocal(ratingId);
          } else {
            failed++; // 403 등: 실패한 항목은 선택 상태를 유지합니다.
          }
        }
      }
    } finally {
      if (!_isOldSession(version)) {
        isDeletingSelected = false;
        _notify();
      }
    }

    if (_isOldSession(version)) return null;
    if (failed == 0) exitEditMode();
    return failed;
  }

  // 401은 세션 정리, 404는 목록에서 제거, 403·409·400은 로그아웃 없이 서버 message만 안내합니다.
  Future<void> _handleWriteError(
    DioException error,
    int version, {
    required int ratingId,
  }) async {
    if (_isOldSession(version)) return;

    final code = apiErrorCode(error);
    if (isAuthExpiredCode(code)) {
      // 세션을 정리하면 Router가 /login으로 보내고, 로그인 화면이 만료 안내를 보여줍니다.
      await _auth.expireSession();
      return;
    }
    if (code == 'RATING404_1') {
      _removeLocal(ratingId);
    }
    message = writeErrorMessage(error);
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestVersion++;
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}