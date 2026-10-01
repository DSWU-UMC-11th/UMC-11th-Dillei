import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/movie.dart';
import '../widgets/rating_dialog.dart';

class MovieDetailScreen extends StatefulWidget {
  final String movieId;
  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false;
  double? _userRating;

  @override
  Widget build(BuildContext context) {
    final movie = findMovieById(int.tryParse(widget.movieId));
    final screenHeight = MediaQuery.sizeOf(context).height;

    if (movie == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cinema Archive')),
        body: const Center(child: Text('해당 영화 정보를 찾을 수 없습니다.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5B4FA9)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Cinema Archive',
          style: TextStyle(
            color: Color(0xFF5B4FA9),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // 세로 길이가 길게 잡힌 대형 포스터
                SizedBox(
                  height: screenHeight * 0.52,
                  width: double.infinity,
                  child: Image.asset(
                    movie.posterAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(color: Colors.grey.shade900),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${movie.year} · ${movie.tags.take(2).join('/')} · ${movie.runtimeMinutes}분',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(height: 12),

                      // 보라색 채워진 별 4개 + 외곽선 테두리가 있는 반쪽 별 1개
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            IconData iconData;
                            if (index < 4) {
                              iconData = Icons.star;
                            } else {
                              iconData = Icons.star_half; // 반쪽 보라색 + 외곽선 테두리
                            }
                            return Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Icon(
                                iconData,
                                size: 18,
                                color: const Color(0xFF5B4FA9),
                              ),
                            );
                          }),
                          const SizedBox(width: 6),
                          Text(
                            '4.5 (${movie.ratingCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')})',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 회색 배경 + 검정 글씨의 둥근 라운드 태그들
                      Wrap(
                        spacing: 8,
                        children: movie.tags
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFEFF2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '시놉시스',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        movie.synopsis,
                        style: const TextStyle(fontSize: 13, height: 1.6, color: Colors.black87),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 하단 액션 바: 정확히 1:1 너비 분할 및 둥근 알약 스타일
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                // 1. 즐겨찾기 버튼 (클릭 시 보라색으로 꽉 채워진 북마크 아이콘)
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _isFavorite ? const Color(0xFFECEBFA) : Colors.white,
                        side: const BorderSide(color: Color(0xFF5B4FA9), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        setState(() => _isFavorite = !_isFavorite);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isFavorite ? '즐겨찾기에 추가되었습니다.' : '즐겨찾기에서 제거되었습니다.'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                            color: const Color(0xFF5B4FA9),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '즐겨찾기',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5B4FA9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 2. 평점 남기기 버튼 (보라색 채움 + 말풍선 연필 아이콘)
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B4FA9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () async {
                        final selectedRating = await showDialog<double>(
                          context: context,
                          builder: (_) => RatingDialog(initialRating: _userRating ?? 4.5),
                        );
                        if (selectedRating != null) {
                          setState(() => _userRating = selectedRating);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('평점 $selectedRating 점이 반영되었습니다.'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.rate_review_outlined, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            _userRating == null ? '평점 남기기' : '평점 수정 ($_userRating)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
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
}