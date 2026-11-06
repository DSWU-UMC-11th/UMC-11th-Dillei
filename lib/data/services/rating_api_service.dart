import 'package:dio/dio.dart';

import '../models/rating_dto.dart';
import '../models/rating_request.dart';

class RatingApiService {
  RatingApiService(this._dio);

  final Dio _dio;

  // TEMP: "저장 성공 후 GET만 실패" 인증 영상용. 인증이 끝나면 이 변수와 아래 if 블록을 지우세요.
  static bool debugFailNextFetch = false;

  // 내 평점 조회 (200 + 직접 배열)
  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    if (debugFailNextFetch) {
      debugFailNextFetch = false;
      throw DioException(
        requestOptions: RequestOptions(path: '/debug'),
        type: DioExceptionType.connectionError,
      );
    }

    final response = await _dio.get('/v6/members/$memberId/ratings');
    final list = response.data as List<dynamic>;

    return list
        .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // 평점 등록 (201 + wrapper). result는 계약이 불확실해서 파싱하지 않습니다.
  Future<void> createRating({
    required int memberId,
    required CreateRatingRequest request,
  }) async {
    final response = await _dio.post(
      '/v6/members/$memberId/ratings',
      data: request.toJson(),
    );
    if (response.statusCode != 201) {
      throw StateError('예상하지 못한 등록 응답: ${response.statusCode}');
    }
  }

  // 평점 수정 (200 + result null).
  // comment를 생략하면 기존 후기가 null로 덮이므로 항상 명시해서 보냅니다.
  Future<void> updateRating({
    required int memberId,
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    await _dio.patch(
      '/v6/members/$memberId/ratings/$ratingId',
      data: {'score': score, 'comment': comment},
    );
  }

  // 평점 삭제 (204, body 없음 → 파싱하지 않음)
  Future<void> deleteRating({
    required int memberId,
    required int ratingId,
  }) async {
    final response = await _dio.delete(
      '/v6/members/$memberId/ratings/$ratingId',
    );
    if (response.statusCode != 204) {
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

// 403·404는 화면의 목록이 서버 상태와 어긋났다는 뜻이므로 다시 조회합니다.
bool shouldRefreshAfterRatingError(DioException error) {
  final data = error.response?.data;
  final code = data is Map<String, dynamic> ? data['code'] as String? : null;
  return code == 'COMMON403' || code == 'COMMON404';
}