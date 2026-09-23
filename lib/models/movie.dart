class Movie {
  final int id;
  final String title;
  final String genre;
  final int year;
  final int runtimeMinutes;
  final double rating;
  final int ratingCount;
  final String synopsis;
  final List<String> tags;
  final String posterAsset;

  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.runtimeMinutes,
    required this.rating,
    required this.ratingCount,
    required this.synopsis,
    required this.tags,
    required this.posterAsset,
  });
}

const List<Movie> mockMovies = [
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    year: 2024,
    runtimeMinutes: 124,
    rating: 4.8,
    ratingCount: 1245,
    synopsis: '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다.',
    tags: ['로맨스', '드라마', '감동적인'],
    posterAsset: 'assets/images/movie_1.png',
  ),
  Movie(
    id: 2,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    runtimeMinutes: 145,
    rating: 4.2,
    ratingCount: 980,
    synopsis: '인류의 새 보금자리를 찾아 떠난 탐사선이 시공간의 왜곡을 마주하며 벌어지는 서스펜스.',
    tags: ['SF', '미스터리', '우주'],
    posterAsset: 'assets/images/movie_2.png',
  ),
  Movie(
    id: 3,
    title: '기억의 숲',
    genre: '애니메이션',
    year: 2024,
    runtimeMinutes: 110,
    rating: 4.9,
    ratingCount: 2100,
    synopsis: '어린 시절 잃어버린 기억을 찾아 떠나는 신비로운 숲속 모험기.',
    tags: ['애니메이션', '판타지', '힐링'],
    posterAsset: 'assets/images/movie_3.png',
  ),
  Movie(
    id: 4,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2024,
    runtimeMinutes: 118,
    rating: 3.8,
    ratingCount: 650,
    synopsis: '도심 한복판에서 일어나는 의문의 사건을 추적하는 형사의 치밀한 추리극.',
    tags: ['스릴러', '범죄', '긴장감'],
    posterAsset: 'assets/images/movie_4.png',
  ),
];

Movie? findMovieById(int? id) {
  for (final movie in mockMovies) {
    if (movie.id == id) return movie;
  }
  return null;
}