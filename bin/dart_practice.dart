// ignore_for_file: avoid_print, unnecessary_nullable_for_final_variable_declarations

class Movie {
  final int id;
  final String title;

  Movie({required this.id, required this.title});
}

String getDisplayName(String? nickname) {
  return nickname ?? '익명';
}

void main() {
  final movies = [
    Movie(id: 1, title: '인셉션'),
    Movie(id: 2, title: '인터스텔라'),
    Movie(id: 3, title: '라라랜드'),
  ];

  print('=== 영화 목록 ===');
  for (final movie in movies) {
    print('제목: ${movie.title}');
  }

  print('=== map 출력 ===');
  movies.map((m) => m.title).forEach(print);

  final String? nick1 = '영화광';
  final String? nick2 = null;

  print('=== 닉네임 변환 ===');
  print('nick1: ${getDisplayName(nick1)}');
  print('nick2: ${getDisplayName(nick2)}');
}