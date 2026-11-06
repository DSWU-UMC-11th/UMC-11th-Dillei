import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/sign_up_service.dart';

import '../screens/start_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/movie_list_screen.dart';
import '../screens/movie_detail_loader.dart';
import '../screens/profile_screen.dart';
import '../screens/my_ratings_screen.dart';

import '../widgets/main_screen.dart';

import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/my_ratings_view_model.dart';
import '../view_models/sign_up_view_model.dart';
import '../view_models/learning_member_session.dart';

class AppRouter {
  AppRouter._();

  // 하단 탭(ShellRoute) 위가 아니라 최상위 Navigator에 띄우기 위한 key
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/start',
    routes: [
      // 시작 화면
      GoRoute(
        path: '/start',
        builder: (context, state) => const StartScreen(),
      ),

      // 회원가입 화면
      GoRoute(
        path: '/register',
        builder: (context, state) {
          return ChangeNotifierProvider<SignUpViewModel>(
            create: (context) => SignUpViewModel(
              context.read<SignUpService>(),
            ),
            child: const RegisterScreen(),
          );
        },
      ),

      // 메인 화면 및 하단 탭
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(
            currentIndex: _indexFromLocation(state.uri.path),
            child: child,
          );
        },
        routes: [
          // 홈
          GoRoute(
            path: '/home',
            builder: (context, state) {
              return ChangeNotifierProvider<MovieHomeViewModel>(
                create: (context) => MovieHomeViewModel(
                  context.read<TmdbMovieService>(),
                )..loadPopular(),
                child: const HomeScreen(),
              );
            },
          ),

          // 영화 목록
          GoRoute(
            path: '/movies',
            builder: (context, state) {
              return ChangeNotifierProvider<MovieListViewModel>(
                create: (context) => MovieListViewModel(
                  context.read<TmdbMovieService>(),
                )..loadInitial(),
                child: const MovieListScreen(),
              );
            },
          ),

          // 프로필
          GoRoute(
            path: '/my',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              // 내가 등록한 평점 (하단 탭 없이 root Navigator에 표시)
              GoRoute(
                path: 'ratings',
                parentNavigatorKey: rootNavigatorKey,
                redirect: (context, state) {
                  final memberId =
                      context.read<LearningMemberSession>().memberId;
                  return memberId == null ? '/register' : null;
                },
                builder: (context, state) {
                  final memberId =
                      context.read<LearningMemberSession>().memberId!;

                  return ChangeNotifierProvider<MyRatingsViewModel>(
                    create: (context) => MyRatingsViewModel(
                      context.read<RatingApiService>(),
                      context.read<TmdbMovieService>(),
                      memberId,
                    )..load(),
                    child: const MyRatingsScreen(),
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // 영화 상세 화면: URL의 id를 기준으로 하고, extra는 있으면 재사용
      GoRoute(
        path: '/movies/:movieId',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['movieId'] ?? '');
          if (id == null || id < 1) {
            return const Scaffold(
              body: Center(child: Text('영화 ID가 올바르지 않습니다.')),
            );
          }
          final extra = state.extra;
          return MovieDetailLoader(
            movieId: id,
            initialMovie: extra is TmdbMovieDto && extra.id == id ? extra : null,
          );
        },
      ),
    ],
  );

  // 하단 탭 인덱스
  static int _indexFromLocation(String path) {
    if (path.startsWith('/movies')) return 1;
    if (path.startsWith('/my')) return 2;
    return 0;
  }
}