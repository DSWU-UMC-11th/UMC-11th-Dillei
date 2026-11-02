import 'package:dio/dio.dart';
import '../models/tmdb_movie_dto.dart';
import '../models/tmdb_genre_dto.dart'; // 장르 DTO 임포트 확인 (없다면 경로에 맞게 생성/확인)
import '../models/tmdb_movie_page.dart'; // 페이지 DTO 임포트 확인

class TmdbMovieService {
  TmdbMovieService(this._dio);
  final Dio _dio;

  /// 영화 ID로 영화 1편의 상세 정보를 가져옵니다. (404 에러면 null 반환)
  Future<TmdbMovieDto?> findMovieById(int movieId) async {
    try {
      final response = await _dio.get(
        '/movie/$movieId',
        queryParameters: {'language': 'ko-KR'},
      );
      return TmdbMovieDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// 인기 영화 목록 가져오기
  Future<List<TmdbMovieDto>> fetchPopular() async {
    final response = await _dio.get(
      '/movie/popular',
      queryParameters: {'language': 'ko-KR'},
    );
    final results = response.data['results'] as List<dynamic>;
    return results
        .map((json) => TmdbMovieDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// 조건별 영화 검색/발견하기 (페이지네이션 및 장르 필터)
  Future<TmdbMoviePage> discoverMovies({int page = 1, int? genreId}) async {
    final response = await _dio.get(
      '/discover/movie',
      queryParameters: {
        'language': 'ko-KR',
        'page': page,
        if (genreId != null) 'with_genres': genreId.toString(),
      },
    );
    return TmdbMoviePage.fromJson(response.data as Map<String, dynamic>);
  }

  /// 장르 목록 가져오기
  Future<List<TmdbGenreDto>> fetchGenres() async {
    final response = await _dio.get(
      '/genre/movie/list',
      queryParameters: {'language': 'ko-KR'},
    );
    final list = response.data['genres'] as List<dynamic>;
    return list
        .map((json) => TmdbGenreDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}