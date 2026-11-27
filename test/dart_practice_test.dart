// test/dart_practice_test.dart
import 'package:flutter_test/flutter_test.dart';

// 1. Movie Class 정의
class Movie {
  const Movie({required this.id, required this.title});

  final int id;
  final String title;
}

// 2. Nullable 닉네임을 기본값으로 변환하는 함수 (Null Safety)
String getDisplayName(String? nickname) {
  return (nickname != null && nickname.trim().isNotEmpty)
      ? nickname.trim()
      : '이름 없음';
}

void main() {
  test('Dart 0주차 미션 검증', () {
    // 3. 영화 3개를 List<Movie>에 추가
    final List<Movie> movies = [
      const Movie(id: 1, title: '인셉션'),
      const Movie(id: 2, title: '인터스텔라'),
      const Movie(id: 3, title: '라라랜드'),
    ];

    // 4. map을 사용해 영화 제목 출력 및 확인
    final titles = movies.map((movie) => movie.title).toList();
    for (final title in titles) {
      // ignore: avoid_print
      print('영화 제목: $title');
    }

    // 5. Null Safety 테스트
    expect(getDisplayName('무비러버'), '무비러버');
    expect(getDisplayName(null), '이름 없음');
    expect(getDisplayName('   '), '이름 없음');
  });
}