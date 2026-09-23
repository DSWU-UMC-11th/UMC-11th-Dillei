import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final List<String> genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러'];
  String selectedGenre = '전체';

  @override
  Widget build(BuildContext context) {
    final filteredMovies = selectedGenre == '전체'
        ? mockMovies
        : mockMovies.where((m) => m.genre == selectedGenre).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('영화 목록', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 장르 필터 Chip 가로 리스트
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: genres.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final genre = genres[index];
                final isSelected = selectedGenre == genre;
                return ChoiceChip(
                  label: Text(genre),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => selectedGenre = genre);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // 2열 그리드 뷰
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredMovies.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) => MovieCard(movie: filteredMovies[index]),
            ),
          ),
        ],
      ),
    );
  }
}