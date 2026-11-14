import 'package:dio/dio.dart';

import '../models/common_response.dart';
import '../models/rating_dto.dart';
import '../models/rating_request.dart';

// v7 등록·수정 result는 Rating 객체입니다.
RatingDto parseRatingResult(Object? data) {
  if (data is! Map<String, dynamic>) {
    throw StateError('평점 응답 형식이 올바르지 않습니다.');
  }
  final common = CommonResponse<RatingDto>.fromJson(
    data,
    (value) => RatingDto.fromJson(value as Map<String, dynamic>),
  );
  final rating = common.result;
  if (rating == null) throw StateError('평점 result가 없습니다.');
  return rating;
}

// 공개 유저별 조회는 wrapper 없이 배열입니다.
List<RatingDto> parseRatingList(Object? data) {
  if (data is! List) throw StateError('평점 목록 응답은 배열이어야 합니다.');
  return data
      .map((value) => RatingDto.fromJson(value as Map<String, dynamic>))
      .toList();
}

class RatingApiService {
  RatingApiService(this._publicDio, this._authDio);

  final Dio _publicDio; // 공개 조회용: Interceptor 없음
  final Dio _authDio; // 등록/수정/삭제용: AuthInterceptor 등록

  /// 공개 API: memberId path 유지, 토큰 없음.
  /// v7 로그인에는 memberId가 없어서 이번 평점 화면은 이 메서드를 쓰지 않습니다.
  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _publicDio.get('/v7/members/$memberId/ratings');
    return parseRatingList(response.data);
  }

  // 평점 등록: path와 body에 memberId가 없습니다. result의 Rating 객체를 돌려줍니다.
  Future<RatingDto> createRating(CreateRatingRequest request) async {
    final response = await _authDio.post(
      '/v7/ratings',
      data: request.toJson(),
    );
    return parseRatingResult(response.data);
  }

  // 평점 수정: PATCH는 부분 수정이 아니라 전체 교체입니다.
  // comment를 생략하면 null로 덮어써지므로 score와 comment를 항상 함께 보냅니다.
  Future<RatingDto> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final response = await _authDio.patch(
      '/v7/ratings/$ratingId',
      data: {'score': score, 'comment': comment},
    );
    return parseRatingResult(response.data);
  }

  // 평점 삭제: v7 성공은 204가 아니라 result가 null인 200입니다.
  Future<void> deleteRating(int ratingId) async {
    final response = await _authDio.delete('/v7/ratings/$ratingId');
    if (response.statusCode != 200) {
      throw StateError('예상하지 못한 삭제 응답: ${response.statusCode}');
    }
  }
}

// 서버 공통 응답의 message를 그대로 사용합니다. (400/403/404/409 모두 동일)
String writeErrorMessage(DioException error) {
  final data = error.response?.data;
  if (data is Map<String, dynamic>) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
  }
  return '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}