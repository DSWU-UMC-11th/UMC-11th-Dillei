import 'package:flutter/material.dart';
import '../widgets/movie_rating_input.dart'; // 💡 별점 입력 위젯 임포트

class MovieDetailScreen extends StatefulWidget {
  final String? movieId;
  final dynamic movie; // 목록에서 전달받은 영화 데이터

  const MovieDetailScreen({
    super.key,
    required this.movieId,
    this.movie,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isFavorite = false; // 즐겨찾기 상태
  double userRating = 0.0;  // 사용자가 남긴 평점 저장 변수

  // 평점 남기기 다이얼로그 띄우기 함수
  void _showRatingDialog(BuildContext context) {
    double tempRating = userRating > 0 ? userRating : 4.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            '영화 평점 주기',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('이 영화에 대한 별점을 남겨주세요!'),
              const SizedBox(height: 20),
              // 💡 이미 만들어두신 MovieRatingInput 위젯 활용
              MovieRatingInput(
                rating: tempRating,
                onChanged: (rating) {
                  tempRating = rating;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  userRating = tempRating;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('평점 ${userRating.toStringAsFixed(1)}점이 등록되었습니다!'),
                    duration: const Duration(seconds: 15),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B4FA9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('확인', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    // 데이터 안전 추출
    String posterUrl = '';
    String title = '영화 상세 정보';
    String releaseYear = '2024';
    double voteAverage = 0.0;
    int voteCount = 0;
    String overview = '';

    if (movie != null) {
      try {
        final path = movie.posterPath?.toString() ?? '';
        if (path.isNotEmpty) {
          posterUrl = path.startsWith('http') ? path : 'https://image.tmdb.org/t/p/w500$path';
        }
      } catch (_) {}

      try {
        title = movie.title?.toString() ?? '제목 없음';
      } catch (_) {}

      try {
        final date = movie.releaseDate?.toString() ?? '';
        if (date.length >= 4) {
          releaseYear = date.substring(0, 4);
        }
      } catch (_) {}

      try {
        voteAverage = double.tryParse(movie.voteAverage?.toString() ?? '0') ?? 0.0;
      } catch (_) {}

      try {
        voteCount = int.tryParse(movie.voteCount?.toString() ?? '0') ?? 0;
      } catch (_) {}

      try {
        overview = movie.overview?.toString() ?? '';
      } catch (_) {}
    }

    if (overview.isEmpty) {
      overview = '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가는 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다. 매일 밤 별을 관측하며 서로의 아픔을 치유해 나가는 감동적인 스토리입니다.';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Cinema Archive',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5C527F)),
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
                  // 1. 상단 대형 포스터 이미지 배너
                  SizedBox(
                    width: double.infinity,
                    height: 380,
                    child: posterUrl.isNotEmpty
                        ? Image.network(
                            posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Center(child: Icon(Icons.movie, size: 60, color: Colors.grey)),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. 영화 제목
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // 3. 연도 · 장르 · 상영시간
                        Text(
                          '$releaseYear · 드라마 · 120분',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // 4. 별점 및 평점 수 (사용자가 매긴 평점이 있으면 반영)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              userRating > 0 
                                  ? userRating.toStringAsFixed(1) 
                                  : (voteAverage > 0 ? voteAverage.toStringAsFixed(1) : '4.8'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              voteCount > 0 ? '($voteCount명 참여)' : '(1,245명 참여)',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                            if (userRating > 0) ...[
                              const SizedBox(width: 8),
                              const Text('(내 평점)', style: TextStyle(fontSize: 11, color: Color(0xFF7C6FCD), fontWeight: FontWeight.bold)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),
                        // 5. 장르 칩 리스트
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildGenreChip('드라마'),
                            _buildGenreChip('감동적인'),
                            _buildGenreChip('로맨스'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // 6. 시놉시스 섹션
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
          // 7. 하단 고정 버튼 영역 (즐겨찾기 / 평점 남기기)
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
            child: Row(
              children: [
                // 즐겨찾기 버튼
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isFavorite ? '즐겨찾기에 추가되었습니다.' : '즐겨찾기에서 해제되었습니다.'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(
                      isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      color: isFavorite ? const Color(0xFF5B4FA9) : Colors.black87,
                    ),
                    label: Text(
                      isFavorite ? '즐겨찾기 취소' : '즐겨찾기',
                      style: TextStyle(
                        color: isFavorite ? const Color(0xFF5B4FA9) : Colors.black87,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isFavorite ? const Color(0xFF5B4FA9) : Colors.grey,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 평점 남기기 버튼 (다이얼로그 연결)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showRatingDialog(context),
                    icon: const Icon(Icons.rate_review_outlined, color: Colors.white),
                    label: const Text('평점 남기기', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B4FA9),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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

  // 둥근 장르 칩 위젯 헬퍼
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