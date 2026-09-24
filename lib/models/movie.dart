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
  final int? rank; // 인기 영화 랭킹 표시용

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
    this.rank,
  });
}

const List<Movie> mockMovies = [
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    year: 2023,
    runtimeMinutes: 124,
    rating: 4.8,
    ratingCount: 1245,
    synopsis:
        '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다. 매일 밤 별을 관측하며 서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시금 깨닫게 되는 따뜻한 이야기입니다.\n\n과거의 아픔으로 인해 사람에게 마음을 열지 못하던 여주인공은, 별자리처럼 변함없는 모습으로 자신을 기다려주는 남주인공을 통해 서서히 마음의 문을 열게 됩니다. 하지만 두 사람 앞에 놓인 현실적인 장벽들은 그들의 관계를 시험하게 되는데...\n\n별이 쏟아지는 밤하늘 아래, 그들이 나눈 조용한 약속들은 과연 영원할 수 있을까요? 눈부신 영상미와 감성적인 OST가 어우러져 깊은 여운을 남기는 올 겨울 최고의 로맨스 영화.',
    tags: ['로맨스', '드라마', '감동적인'],
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
    rank: 1,
  ),
  Movie(
    id: 2,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    runtimeMinutes: 145,
    rating: 4.2,
    ratingCount: 980,
    synopsis: '인류의 새 보금자리를 찾아 떠난 탐사선이 시공간의 왜곡을 마주하며 벌어지는 광활한 우주 서스펜스.',
    tags: ['SF', '미스터리', '우주'],
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    rank: 2,
  ),
  Movie(
    id: 3,
    title: '기억의 숲',
    genre: '애니메이션',
    year: 2022,
    runtimeMinutes: 105,
    rating: 4.9,
    ratingCount: 2100,
    synopsis: '어린 시절 잃어버린 기억을 찾아 비밀의 숲으로 떠나는 소녀와 숲의 정령들이 그리는 환상적인 모험.',
    tags: ['애니메이션', '판타지', '힐링'],
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    rank: 3,
  ),
  Movie(
    id: 4,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2024,
    runtimeMinutes: 118,
    rating: 3.8,
    ratingCount: 650,
    synopsis: '도심 한복판에서 일어나는 의문의 사건을 추적하는 베테랑 형사의 치밀하고 숨 막히는 추리극.',
    tags: ['스릴러', '범죄', '긴장감'],
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
  ),
  Movie(
    id: 5,
    title: '봄날의 커피',
    genre: '로맨스',
    year: 2021,
    runtimeMinutes: 98,
    rating: 4.5,
    ratingCount: 890,
    synopsis: '오래된 골목 어귀의 작은 카페에서 시작되는 향긋한 커피와 설레는 첫사랑의 기억.',
    tags: ['로맨스', '일상', '따뜻한'],
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
  ),
  Movie(
    id: 6,
    title: '도시의 선',
    genre: '다큐멘터리',
    year: 2023,
    runtimeMinutes: 85,
    rating: 4.1,
    ratingCount: 420,
    synopsis: '빠르게 변화하는 현대 도시의 건축과 그 속에서 살아가는 사람들의 삶을 기록한 다큐멘터리.',
    tags: ['다큐멘터리', '건축', '도시'],
    posterAsset: 'assets/images/posters/poster_abyss_walker.jpg',
  ),
];

Movie? findMovieById(int? id) {
  for (final movie in mockMovies) {
    if (movie.id == id) return movie;
  }
  return null;
}