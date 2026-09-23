import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/movie.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final heroMovie = mockMovies.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MovieLog', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 8),
          const Text('오늘은 어떤\n영화를 볼까요?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3)),
          const SizedBox(height: 16),
          // 대형 추천 배너
          GestureDetector(
            onTap: () => context.push('/movies/${heroMovie.id}'),
            child: Container(
              height: 380,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(heroMovie.posterAsset),
                  fit: BoxFit.cover,
                  onError: (_, _) {},
                ),
                color: Colors.grey.shade900,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('추천 신작', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      heroMovie.title,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${heroMovie.tags.join(' · ')} · ${heroMovie.runtimeMinutes}분',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/movies/${heroMovie.id}'),
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('상세보기'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('인기 영화', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => context.go('/movies'),
                child: const Text('전체보기 >'),
              ),
            ],
          ),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: mockMovies.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final movie = mockMovies[index];
                return GestureDetector(
                  onTap: () => context.push('/movies/${movie.id}'),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 120,
                      color: Colors.grey.shade200,
                      child: Image.asset(
                        movie.posterAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(child: Text(movie.title, textAlign: TextAlign.center)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}