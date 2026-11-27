import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../data/models/rating_request.dart';
import '../data/services/rating_api_service.dart';
import 'auth_view_model.dart';
import 'my_ratings_view_model.dart';

enum RatingSubmitStatus {
  idle,
  submitting,
  success,
  error,
}

class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(
    this._ratingService,
    this._auth,
    this._myRatings,
  );

  final RatingApiService _ratingService;
  final AuthViewModel _auth;
  final MyRatingsViewModel _myRatings;

  RatingSubmitStatus submitStatus = RatingSubmitStatus.idle;
  String? errorMessage;
  bool _disposed = false;

  bool get isSubmitting => submitStatus == RatingSubmitStatus.submitting;

  Future<bool> submitRating({
    required int movieId,
    required int score,
    String? comment,
  }) async {
    if (isSubmitting) return false;

    // 로그인 여부는 토큰이 아니라 AuthViewModel 상태(서버 검증을 거친 signedIn)로 판단합니다.
    if (_auth.status != AuthStatus.signedIn) {
      _fail('로그인이 필요해요. 다시 로그인해 주세요.');
      return false;
    }

    if (score < 1 || score > 5) {
      _fail('평점은 1점부터 5점까지 입력할 수 있습니다.');
      return false;
    }

    final version = _auth.sessionVersion;
    submitStatus = RatingSubmitStatus.submitting;
    errorMessage = null;
    _notify();

    try {
      // v7: path와 body에 memberId가 없습니다. Interceptor가 Authorization 헤더를 붙입니다.
      final created = await _ratingService.createRating(
        CreateRatingRequest(
          movieId: movieId,
          score: score,
          comment: comment,
        ),
      );

      // 로그아웃·회원 전환 뒤 늦게 도착한 응답은 화면에 반영하지 않습니다.
      if (_isOldSession(version)) {
        _reset();
        return false;
      }

      // 등록 result의 Rating을 "내가 등록한 평점" 목록에 추가합니다.
      _myRatings.addCreated(created, sessionVersion: version);

      submitStatus = RatingSubmitStatus.success;
      _notify();
      return true;
    } on DioException catch (error) {
      if (_isOldSession(version)) {
        _reset();
        return false;
      }

      final code = apiErrorCode(error);
      if (isAuthExpiredCode(code)) {
        // 401(AUTH401_2/3/4): 세션을 정리하면 Router가 /login으로 보냅니다.
        _fail('로그인이 만료됐어요. 다시 로그인해 주세요.');
        await _auth.expireSession();
        return false;
      }

      // 400/403/404/409는 로그아웃하지 않고 서버 message를 그대로 보여줍니다.
      _fail(writeErrorMessage(error));
      return false;
    } catch (_) {
      if (_isOldSession(version)) {
        _reset();
        return false;
      }
      _fail('예상하지 못한 오류가 발생했습니다.');
      return false;
    }
  }

  void resetStatus() {
    _reset();
  }

  bool _isOldSession(int version) =>
      _disposed || version != _auth.sessionVersion;

  void _fail(String message) {
    submitStatus = RatingSubmitStatus.error;
    errorMessage = message;
    _notify();
  }

  void _reset() {
    submitStatus = RatingSubmitStatus.idle;
    errorMessage = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}