// lib/widgets/movie_grid.dart
import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'movie_card.dart'; // 3주차에 작성된 카드 위젯

class MovieGrid extends StatelessWidget {
  const MovieGrid({
    super.key,
    required this.movies,
  });

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // 3번째 사진의 좌우/상하 패딩
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        // 3번째 사진의 세로로 긴 포스터 카드 비율 (가로/세로 비율: 약 0.52~0.54)[cite: 6]
        childAspectRatio: 0.53,
        crossAxisSpacing: 14,
        mainAxisSpacing: 20,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        return MovieCard(movie: movies[index]);
      },
    );
  }
}