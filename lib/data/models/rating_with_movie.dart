import 'rating_dto.dart';
import 'tmdb_movie_dto.dart';

class RatingWithMovie {
  const RatingWithMovie({
    required this.rating,
    this.movie,
  });

  final RatingDto rating;
  final TmdbMovieDto? movie; // 영화 정보를 못 찾았으면 null입니다.
}