// lib/services/fake_movie_service.dart
// 3주차 Movie 모델과 mockMovies 리스트가 정의된 파일 경로로 import 경로를 맞춰주세요.
import '../models/movie.dart';

enum MovieLoadMode { success, empty, failure }

class MovieLoadException implements Exception {
  const MovieLoadException(this.message);
  final String message;

  @override
  String toString() => message;
}

class FakeMovieService {
  const FakeMovieService();

  
  Future<List<Movie>> fetchMovies({
    MovieLoadMode mode = MovieLoadMode.success,
  }) async {
    // 최소 800ms 이상 지연을 보장하기 위해 1초(1000ms) 대기
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    return switch (mode) {
      MovieLoadMode.success => mockMovies, // 3주차 Mock Movie 리스트 변수명
      MovieLoadMode.empty => const <Movie>[],
      MovieLoadMode.failure =>
        throw const MovieLoadException('영화를 불러오는 중 문제가 발생했습니다.'),
    };
  }
}