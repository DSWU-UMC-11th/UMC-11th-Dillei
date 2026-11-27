import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../view_models/load_phase.dart';
import '../view_models/paged_movies_view_model.dart';
import '../widgets/movie_page_footer.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '영화',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () => context.push('/movies/search'),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Consumer<PagedMoviesViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // 1. 상단 장르 필터 칩 (항상 표시)
              _buildGenreChips(viewModel),
              const SizedBox(height: 8),
              // 2. 상태별 본문
              Expanded(child: _buildBody(context, viewModel)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGenreChips(PagedMoviesViewModel viewModel) {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: viewModel.genres.length + 1,
        itemBuilder: (context, index) {
          final isSelected =
              (index == 0 && viewModel.selectedGenreId == null) ||
                  (index > 0 &&
                      viewModel.selectedGenreId ==
                          viewModel.genres[index - 1].id);

          final labelText =
              index == 0 ? '전체' : viewModel.genres[index - 1].name;
          final genreId = index == 0 ? null : viewModel.genres[index - 1].id;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => viewModel.selectGenre(genreId),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF5B4FA9)
                      : const Color(0xFFEFECE9),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  labelText,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, PagedMoviesViewModel viewModel) {
    return switch (viewModel.phase) {
      LoadPhase.idle || LoadPhase.loading => const Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      LoadPhase.error => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(viewModel.errorMessage ?? '영화를 불러오지 못했어요.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.loadInitial(
                  genreId: viewModel.selectedGenreId,
                ),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      LoadPhase.empty => const Center(child: Text('등록된 영화가 없습니다.')),
      LoadPhase.ready => _buildGrid(context, viewModel),
    };
  }

  Widget _buildGrid(BuildContext context, PagedMoviesViewModel viewModel) {
    // 그리드 + 맨 아래 footer(더 보기/재시도/끝)를 한 스크롤에 담습니다.
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 14,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildMovieCard(context, viewModel, viewModel.movies[index]),
              childCount: viewModel.movies.length,
            ),
          ),
        ),
        SliverToBoxAdapter(child: MoviePageFooter(vm: viewModel)),
      ],
    );
  }

  Widget _buildMovieCard(
    BuildContext context,
    PagedMoviesViewModel viewModel,
    TmdbMovieDto movie,
  ) {
    final posterUrl =
        movie.posterPath != null && movie.posterPath!.isNotEmpty
            ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
            : '';

    String yearStr = '2024';
    if (movie.releaseDate != null && movie.releaseDate!.length >= 4) {
      yearStr = movie.releaseDate!.substring(0, 4);
    }

    String genreStr = '드라마';
    if (movie.genreIds.isNotEmpty && viewModel.genres.isNotEmpty) {
      try {
        final matchedGenre = viewModel.genres.firstWhere(
          (g) => g.id == movie.genreIds.first,
        );
        genreStr = matchedGenre.name;
      } catch (_) {
        genreStr = '영화';
      }
    }

    return GestureDetector(
      onTap: () {
        context.push('/movies/${movie.id}', extra: movie);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: posterUrl.isNotEmpty
                      ? Image.network(
                          posterUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child:
                                Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.movie, size: 40, color: Colors.grey),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$yearStr · $genreStr',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}