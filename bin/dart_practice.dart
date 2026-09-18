// bin/dart_practice.dart

// 1. Movie Class 정의 (Named Parameter 사용)
class Movie {
  const Movie({
    required this.id,
    required this.title,
  });

  final int id;
  final String title;
}

// 2. Nullable 닉네임을 안전한 기본값으로 변환하는 함수 (Null Safety)
String getDisplayName(String? nickname) {
  return (nickname != null && nickname.trim().isNotEmpty)
      ? nickname.trim()
      : '이름 없음';
}

void main() {
  print('=== Mission 2: Dart 문법 실습 ===\n');

  // 3. 영화 3개를 List<Movie>에 추가
  final List<Movie> movieList = [
    const Movie(id: 1, title: '인셉션'),
    const Movie(id: 2, title: '인터스텔라'),
    const Movie(id: 3, title: '라라랜드'),
  ];

  // 4. map과 for를 사용해 영화 제목 출력
  print('[영화 목록]');
  final titles = movieList.map((movie) => movie.title).toList();
  for (final title in titles) {
    print('- $title');
  }

  print('\n[Null Safety 닉네임 변환 결과]');
  // 5. 다양한 닉네임 케이스 검증 출력
  final String? user1 = '무비러버';
  final String? user2 = null;
  final String? user3 = '   ';

  print('user1 ("무비러버"): ${getDisplayName(user1)}');
  print('user2 (null): ${getDisplayName(user2)}');
  print('user3 ("   "): ${getDisplayName(user3)}');
}