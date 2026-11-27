import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/favorite_list_item.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../view_models/favorites_view_model.dart';
import '../view_models/load_phase.dart';
import '../widgets/movielog_button.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key, required this.onOpenMovie});

  final Future<void> Function(TmdbMovieDto movie) onOpenMovie;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // 평점 화면과 같은 느낌의 색상
  static const _violet = Color(0xFF5B4FA9);
  static const _lavender = Color(0xFFEDE9F7);
  static const _border = Color(0xFFD9D3E8);
  static const _titleColor = Color(0xFF2B2B33);
  static const _errorColor = Color(0xFF9B2C2C);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FavoritesViewModel>().refresh();
    });
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}.${two(local.month)}.${two(local.day)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          '내 즐겨찾기',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: _violet,
          ),
        ),
      ),
      body: Consumer<FavoritesViewModel>(
        builder: (context, vm, _) {
          if (vm.phase == LoadPhase.idle || vm.phase == LoadPhase.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.phase == LoadPhase.empty) {
            return const Center(child: Text('아직 즐겨찾기한 영화가 없습니다.'));
          }
          if (vm.phase == LoadPhase.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(vm.errorMessage ?? '조회 오류입니다.'),
                  const SizedBox(height: 12),
                  MovieLogButton(label: '다시 시도', onPressed: vm.refresh),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: vm.refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: vm.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildCard(context, vm, vm.items[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    FavoritesViewModel vm,
    FavoriteListItem item,
  ) {
    final movie = item.movie;
    final registered = _formatDate(item.favorite.createdAt);

    // 영화 정보 1건 조회 실패: 같은 카드 모양 + 재조회 버튼 (다른 카드는 그대로)
    if (movie == null) {
      return Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _posterBox(null),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '영화 #${item.favorite.movieId}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: _titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '즐겨찾기 $registered',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _violet,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.errorMessage ?? '영화 정보를 불러오지 못했습니다.',
                      style: const TextStyle(fontSize: 12, color: _errorColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: vm.refresh,
                child: _pill('재조회'),
              ),
            ],
          ),
        ),
      );
    }

    final date = movie.releaseDate ?? '';
    final year = date.length >= 4 ? date.substring(0, 4) : '-';
    final vote =
        movie.voteAverage > 0 ? movie.voteAverage.toStringAsFixed(1) : '-';

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _border),
      ),
      child: InkWell(
        onTap: () async {
          await widget.onOpenMovie(movie);
          if (!mounted) return;
          await vm.refresh(); // 상세에서 해제하고 돌아오면 목록을 다시 조회합니다.
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _posterBox(movie.posterPath),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: _titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '즐겨찾기 $registered',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: _violet,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$year · ★ $vote',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _pill('상세'), // 카드 전체를 누르면 영화 상세로 이동합니다.
            ],
          ),
        ),
      ),
    );
  }

  // 둥근 포스터 (포스터가 없으면 회색 상자 + 아이콘)
  Widget _posterBox(String? posterPath) {
    final hasPoster = posterPath != null && posterPath.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        height: 108,
        child: hasPoster
            ? Image.network(
                'https://image.tmdb.org/t/p/w342$posterPath',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image_outlined,
                      color: Colors.grey),
                ),
              )
            : Container(
                color: Colors.grey[200],
                child: const Icon(Icons.movie_outlined, color: Colors.grey),
              ),
      ),
    );
  }

  // 평점 화면의 '수정' 버튼 같은 연보라 알약 모양
  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: _lavender,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: _violet,
        ),
      ),
    );
  }
}