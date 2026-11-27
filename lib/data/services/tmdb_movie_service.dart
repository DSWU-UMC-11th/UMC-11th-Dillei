import 'package:dio/dio.dart';
import '../models/tmdb_movie_dto.dart';
import '../models/tmdb_genre_dto.dart';
import '../models/tmdb_movie_page.dart';

class TmdbMovieService {
  TmdbMovieService(this._dio);
  final Dio _dio;

  /// 영화 ID로 영화 1편의 상세 정보를 가져옵니다. (404 에러면 null 반환)
  /// 영화 상세 화면(MovieDetailLoader)에서 사용합니다.
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

  /// 영화 상세 조회: 내 즐겨찾기 목록의 movieId로 제목·포스터를 채울 때 사용합니다.
  /// 실패하면 예외를 던지고, 호출하는 쪽(FavoritesViewModel)이 그 카드만 실패로 표시합니다.
  Future<TmdbMovieDto> fetchMovieDetails(int movieId) async {
    final response = await _dio.get(
      '/movie/$movieId',
      queryParameters: {'language': 'ko-KR'},
    );
    return TmdbMovieDto.fromJson(response.data as Map<String, dynamic>);
  }

  /// 인기 영화 목록 가져오기 (홈 화면의 인기 영화 API, 수정하지 않습니다)
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

  /// 조건별 영화 발견하기 (페이지네이션 및 장르 필터)
  Future<TmdbMoviePage> discoverMovies({int page = 1, int? genreId}) async {
    final response = await _dio.get(
      '/discover/movie',
      queryParameters: {
        'language': 'ko-KR',
        'page': page,
        'include_adult': false,
        'sort_by': 'popularity.desc',
        if (genreId != null) 'with_genres': genreId.toString(),
      },
    );
    return TmdbMoviePage.fromJson(response.data as Map<String, dynamic>);
  }

  /// 영화 검색 (검색어가 비어 있으면 호출하지 않습니다. ViewModel에서 먼저 막습니다)
  Future<TmdbMoviePage> searchMovies({
    required int page,
    required String query,
  }) async {
    final response = await _dio.get(
      '/search/movie',
      queryParameters: {
        'query': query,
        'page': page,
        'language': 'ko-KR',
        'include_adult': false,
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