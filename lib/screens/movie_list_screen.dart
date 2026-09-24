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
      backgroundColor: const Color(0xFFFBFBFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFBFC),
        elevation: 0,
        title: const Text(
          '영화',
          style: TextStyle(
            color: Color(0xFF5B4FA9),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF5B4FA9), size: 26),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 38,
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
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  selectedColor: const Color(0xFF5B4FA9),
                  backgroundColor: const Color(0xFFECEBFA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide.none,
                  showCheckmark: false,
                  onSelected: (val) {
                    if (val) setState(() => selectedGenre = genre);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // 4개만 화면에 딱 채워지도록 childAspectRatio 조정 (0.55)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredMovies.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
                childAspectRatio: 0.55, // 포스터 세로 길이를 늘려 첫 화면에 4개만 노출
              ),
              itemBuilder: (context, index) => MovieCard(movie: filteredMovies[index]),
            ),
          ),
        ],
      ),
    );
  }
}