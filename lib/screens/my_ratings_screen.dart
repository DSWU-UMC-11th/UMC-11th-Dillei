import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/my_ratings_view_model.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  static const Color primaryColor = Color(0xFF6653A5);
  static const Color backgroundColor = Color(0xFFFBFAF8);
  static const Color borderColor = Color(0xFFDAD4E3);
  static const Color textColor = Color(0xFF29252D);
  static const Color subTextColor = Color(0xFF817B88);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // 상단 앱바
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: textColor,
            size: 27,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '내가 등록한 평점',
          style: TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // 평점 데이터
      body: Consumer<MyRatingsViewModel>(
        builder: (context, viewModel, child) {
          // 1. 로딩 상태
          if (viewModel.status == MyRatingsLoadStatus.loading ||
              viewModel.status == MyRatingsLoadStatus.idle) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }

          // 2. 에러 상태
          if (viewModel.status == MyRatingsLoadStatus.error) {
            return _buildErrorView(viewModel);
          }

          // 3. 평점이 없는 상태
          if (viewModel.status == MyRatingsLoadStatus.empty ||
              viewModel.ratings.isEmpty) {
            return _buildEmptyView();
          }

          // 4. 평점 목록
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (viewModel.message != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Text(
                    viewModel.message!,
                    style: const TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                    ),
                  ),
                ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    24,
                    20,
                    24,
                  ),
                  itemCount: viewModel.ratings.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = viewModel.ratings[index];

                    final movieTitle =
                        item.movie?.title ?? '영화 #${item.rating.movieId}';

                    final posterPath = item.movie?.posterPath;

                    final comment = item.rating.comment;

                    return _buildRatingCard(
                      movieTitle: movieTitle,
                      posterPath: posterPath,
                      score: item.rating.score,
                      comment: comment,
                      createdAt: item.rating.createdAt,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // 등록일 표시 형식 (예: 2026.09.06)
  // ==========================================

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}.$month.$day';
  }

  // ==========================================
  // 평점 카드
  // ==========================================

  Widget _buildRatingCard({
    required String movieTitle,
    required String? posterPath,
    required dynamic score,
    required String? comment,
    required DateTime createdAt,
  }) {
    return Container(
      height: 176,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: borderColor,
          width: 1.8,
        ),
      ),
      child: Row(
        children: [
          // 영화 포스터
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 92,
              height: 140,
              child: posterPath != null && posterPath.isNotEmpty
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w185$posterPath',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPosterPlaceholder();
                      },
                    )
                  : _buildPosterPlaceholder(),
            ),
          ),

          const SizedBox(width: 18),

          // 영화 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 영화 제목
                Text(
                  movieTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 10),

                // 별점 + 등록일
                Row(
                  children: [
                    Text(
                      '별점 $score / 5',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),

                // 후기 (값이 없으면 표시하지 않음)
                if (comment != null && comment.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    comment,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: subTextColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 포스터가 없을 때 기본 이미지
  // ==========================================

  Widget _buildPosterPlaceholder() {
    return Container(
      color: const Color(0xFFD8D3DF),
      child: const Center(
        child: Icon(
          Icons.movie_outlined,
          size: 35,
          color: Colors.white,
        ),
      ),
    );
  }

  // ==========================================
  // 평점 로딩 실패 화면
  // ==========================================

  Widget _buildErrorView(MyRatingsViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              viewModel.message ?? '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                color: textColor,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: () {
                viewModel.load();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7F0F8),
                foregroundColor: primaryColor,
                elevation: 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 42,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                '다시 시도',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 등록된 평점이 없을 때
  // ==========================================

  Widget _buildEmptyView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border_rounded,
            size: 55,
            color: Color(0xFFD8D3DF),
          ),
          SizedBox(height: 12),
          Text(
            '아직 등록한 평점이 없습니다.',
            style: TextStyle(
              fontSize: 16,
              color: subTextColor,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '영화에 평점을 남겨 나만의 기록을 만들어보세요!',
            style: TextStyle(
              fontSize: 13,
              color: subTextColor,
            ),
          ),
        ],
      ),
    );
  }
}