import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// 메서드 / 경로 / 상태코드만 출력합니다. 헤더·본문(토큰, 이메일 등)은 절대 출력하지 않습니다.
class SafeLogInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[API] ${response.requestOptions.method} '
        '${response.requestOptions.uri.path} -> ${response.statusCode}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '[API] ${err.requestOptions.method} '
        '${err.requestOptions.uri.path} -> ERROR ${err.response?.statusCode ?? err.type.name}',
      );
    }
    handler.next(err);
  }
}