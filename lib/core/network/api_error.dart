import 'package:dio/dio.dart';

/// 서버 오류 응답 body의 `code`를 꺼냅니다. (예: AUTH401_1, RATING403_1)
String? apiErrorCode(DioException error) {
  final data = error.response?.data;
  if (data is! Map<String, dynamic>) return null;
  final code = data['code'];
  return code is String ? code : null;
}

/// 서버 오류 응답 body의 `message`를 꺼냅니다.
String? apiErrorMessage(DioException error) {
  final data = error.response?.data;
  if (data is! Map<String, dynamic>) return null;
  final message = data['message'];
  return message is String ? message : null;
}

/// 보호 요청에서 토큰이 없거나/무효하거나/만료된 경우(AUTH401_2/3/4)입니다.
/// 로그인 입력 오류(AUTH401_1)는 포함하지 않습니다.
bool isAuthExpiredCode(String? code) {
  return code == 'AUTH401_2' || code == 'AUTH401_3' || code == 'AUTH401_4';
}