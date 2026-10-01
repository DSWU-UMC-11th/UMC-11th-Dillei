import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/fake_movie_service.dart';
import '../services/genre_preference.dart';
import '../widgets/movie_grid.dart';
import '../widgets/movie_state_views.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final FakeMovieService _movieService = const FakeMovieService();
  final GenrePreference _genrePreference = GenrePreference();

  late Future<List<Movie>> _moviesFuture;
  String _selectedGenre = '전체';

  // 3번째 사진과 정확히 일치하는 장르 목록
  final List<String> _genres = const ['전체', '드라마', 'SF', '애니메이션', '스릴러'];

  @override
  void initState() {
    super.initState();
    // 1. build 안이 아닌 initState에서 Future 최초 1회 생성
    _moviesFuture = _movieService.fetchMovies();
    _restoreSelectedGenre();
  }

  // 앱 재실행 시 저장된 장르 불러오기
  Future<void> _restoreSelectedGenre() async {
    final savedGenre = await _genrePreference.read();
    if (!mounted) return;
    setState(() {
      _selectedGenre = savedGenre;
    });
  }

  // 장르 선택 및 로컬 저장
  Future<void> _onGenreSelected(String genre) async {
    setState(() {
      _selectedGenre = genre;
    });
    await _genrePreference.save(genre);
  }

  // 에러 화면에서 다시 시도할 때만 새로운 Future 할당
  void _retry() {
    setState(() {
      _moviesFuture = _movieService.fetchMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 배경을 순백색(Colors.white)으로 고정하여 다른 탭 색상 간섭 방지
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          '영화', // 3번째 사진과 동일한 타이틀
          style: TextStyle(
            color: Color(0xFF6750A4), // 3주차 보라색 메인 컬러
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.search, color: Color(0xFF6750A4), size: 28), // 3번째 사진 돋보기 아이콘
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 상단 장르 Chip 가로 스크롤 영역 (3번째 사진 스타일)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _genres.map((genre) {
                final isSelected = _selectedGenre == genre;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      genre,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF49454F),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF6750A4), // 선택 시 보라색
                    backgroundColor: const Color(0xFFF3EDF7), // 비선택 시 연보라
                    showCheckmark: false, // 3번째 사진처럼 체크 표시 제거
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (_) => _onGenreSelected(genre),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // 2. 비동기 상태 분기 처리 영역
          Expanded(
            child: FutureBuilder<List<Movie>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                // (1) Loading 상태
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const MovieListLoading();
                }

                // (2) Error 상태
                if (snapshot.hasError) {
                  return MovieListError(onRetry: _retry);
                }

                final allMovies = snapshot.data ?? const <Movie>[];
                final filteredMovies = _selectedGenre == '전체'
                    ? allMovies
                    : allMovies.where((m) => m.genre == _selectedGenre).toList();

                // (3) Empty 상태
                if (filteredMovies.isEmpty) {
                  return const MovieListEmpty();
                }

                // (4) Success 상태: 3주차 MovieGrid 호출
                return MovieGrid(movies: filteredMovies);
              },
            ),
          ),
        ],
      ),
    );
  }
}