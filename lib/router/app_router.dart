import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/services/tmdb_movie_service.dart';
import '../screens/start_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/main_screen.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/start',
    routes: [
      // 1. 시작 화면
      GoRoute(
        path: '/start',
        builder: (context, state) => const StartScreen(),
      ),
      // 2. 회원가입 화면
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // 3. NavigationBar가 고정되는 메인 셸 (홈, 영화, 마이)
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(
            currentIndex: _indexFromLocation(state.uri.path),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => ChangeNotifierProvider<MovieHomeViewModel>(
              create: (context) => MovieHomeViewModel(
                context.read<TmdbMovieService>(),
              )..loadPopular(),
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) => ChangeNotifierProvider<MovieListViewModel>(
              create: (context) => MovieListViewModel(
                context.read<TmdbMovieService>(),
              )..loadInitial(),
              child: const MovieListScreen(),
            ),
          ),
          GoRoute(
            path: '/my',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // 4. 상세 화면 (뒤로가기 pop 지원을 위해 최상위 스택에 배치)
      GoRoute(
        path: '/movies/:movieId',
        builder: (context, state) {
          final movieId = state.pathParameters['movieId']; 
          final movie = state.extra;
          return MovieDetailScreen(movieId: movieId, movie: movie);
        },
      ),
    ],
  );

  static int _indexFromLocation(String path) {
    if (path.startsWith('/movies')) return 1;
    if (path.startsWith('/my')) return 2;
    return 0;
  }
}