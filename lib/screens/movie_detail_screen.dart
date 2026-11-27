import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/favorite_detail_view_model.dart';
import '../view_models/movie_detail_view_model.dart';
import '../widgets/favorite_button.dart';
import '../widgets/rating_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movie});

  final TmdbMovieDto movie;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  double userRating = 0.0;

  @override
  void initState() {
    super.initState();
    // 화면이 처음 만들어질 때 서버의 즐겨찾기 여부를 한 번만 조회합니다.
    // build()에서는 조회하지 않습니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FavoriteDetailViewModel>().load();
    });
  }

  Future<void> _showRatingDialog() async {
    final viewModel = context.read<MovieDetailViewModel>();
    final auth = context.read<AuthViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final movieId = widget.movie.id; // TmdbMovieDto.id를 그대로 사용

    viewModel.resetStatus();

    int? savedScore;

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 저장 중 바깥 탭 방지
      builder: (dialogContext) => RatingDialog(
        onSubmit: (score, comment) async {
          final ok = await viewModel.submitRating(
            movieId: movieId,
            score: score,
            comment: comment,
          );
          if (!ok) {
            // 세션이 만료돼 로그아웃 상태가 됐다면 Dialog를 닫습니다.
            if (auth.status != AuthStatus.signedIn &&
                dialogContext.mounted) {
              Navigator.of(dialogContext).pop(false);
            }
            throw StateError(viewModel.errorMessage ?? '저장에 실패했습니다.');
          }
          savedScore = score;
        },
      ),
    );

    if (saved != true) return;

    if (mounted && savedScore != null) {
      setState(() => userRating = savedScore!.toDouble());
    }

    messenger.showSnackBar(
      const SnackBar(
        content: Text('평점을 등록했습니다. 마이페이지의 "내가 등록한 평점"에서 확인할 수 있습니다.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    final posterPath = movie.posterPath ?? '';
    final posterUrl = posterPath.isNotEmpty
        ? 'https://image.tmdb.org/t/p/w500$posterPath'
        : '';

    final date = movie.releaseDate ?? '';
    final releaseYear = date.length >= 4 ? date.substring(0, 4) : '-';

    final voteAverage = movie.voteAverage;

    final overview = movie.overview.isNotEmpty
        ? movie.overview
        : '등록된 줄거리가 없습니다.';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Cinema Archive',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C527F),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('공유 링크가 복사되었습니다.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 380,
                    child: posterUrl.isNotEmpty
                        ? Image.network(
                            posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.movie,
                                size: 60,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목·정보 텍스트 + 오른쪽 즐겨찾기 버튼
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$releaseYear · 드라마 · 120분',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const FavoriteButton(),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              userRating > 0
                                  ? userRating.toStringAsFixed(1)
                                  : (voteAverage > 0
                                      ? voteAverage.toStringAsFixed(1)
                                      : '-'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (userRating > 0) ...[
                              const SizedBox(width: 8),
                              const Text(
                                '(내 평점)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF7C6FCD),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildGenreChip('드라마'),
                            _buildGenreChip('감동적인'),
                            _buildGenreChip('로맨스'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '시놉시스',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          overview,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            // 즐겨찾기 버튼이 위로 올라갔으므로 평점 버튼이 전체 너비를 씁니다.
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showRatingDialog,
                    icon: const Icon(
                      Icons.rate_review_outlined,
                      color: Colors.white,
                    ),
                    label: const Text(
                      '평점 남기기',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B4FA9),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F0F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}