import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../data/models/rating_request.dart';
import '../data/services/rating_api_service.dart';
import 'learning_member_session.dart';

enum RatingSubmitStatus {
  idle,
  submitting,
  success,
  error,
}

class MovieDetailViewModel extends ChangeNotifier {
  MovieDetailViewModel(
    this._ratingService,
    this._memberSession,
  );

  final RatingApiService _ratingService;
  final LearningMemberSession _memberSession;

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

    final memberId = _memberSession.memberId;

    if (memberId == null) {
      submitStatus = RatingSubmitStatus.error;
      errorMessage = '먼저 회원가입을 완료해 주세요.';
      _notify();
      return false;
    }

    if (score < 1 || score > 5) {
      submitStatus = RatingSubmitStatus.error;
      errorMessage = '평점은 1점부터 5점까지 입력할 수 있습니다.';
      _notify();
      return false;
    }

    submitStatus = RatingSubmitStatus.submitting;
    errorMessage = null;
    _notify();

    try {
      await _ratingService.createRating(
        memberId: memberId,
        request: CreateRatingRequest(
          movieId: movieId,
          score: score,
          comment: comment,
        ),
      );

      submitStatus = RatingSubmitStatus.success;
      _notify();
      return true;
    } on DioException catch (error) {
      // 400/404/409 모두 서버 message를 그대로 보여줍니다.
      submitStatus = RatingSubmitStatus.error;
      errorMessage = writeErrorMessage(error);
      _notify();
      return false;
    } catch (_) {
      submitStatus = RatingSubmitStatus.error;
      errorMessage = '예상하지 못한 오류가 발생했습니다.';
      _notify();
      return false;
    }
  }

  void resetStatus() {
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