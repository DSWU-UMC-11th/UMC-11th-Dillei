import 'tmdb_movie_dto.dart';

class TmdbMoviePage {
  const TmdbMoviePage({
    required this.page,
    required this.results,
    required this.totalPages,
  });

  final int page;
  final List<TmdbMovieDto> results;
  final int totalPages;

  factory TmdbMoviePage.fromJson(Map<String, dynamic> json) {
    final list = json['results'] as List<dynamic>? ?? [];
    return TmdbMoviePage(
      page: json['page'] as int? ?? 1,
      results: list
          .map((item) => TmdbMovieDto.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}