import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/member_api_service.dart';
import '../data/services/sign_up_service.dart';
import '../data/services/tmdb_movie_service.dart';

import '../screens/edit_profile_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/movie_detail_loader.dart';
import '../screens/movie_list_screen.dart';
import '../screens/my_ratings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';

import '../widgets/main_screen.dart';
import '../widgets/movielog_button.dart';

import '../view_models/auth_view_model.dart';
import '../view_models/edit_profile_view_model.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/sign_up_view_model.dart';

/// 인증 상태에 따른 화면 이동 규칙입니다. 상태만 읽고 판단하며 비동기 작업은 하지 않습니다.
String? authRedirect(AuthStatus status, String location) {
  const publicPaths = {'/login', '/register'};
  final atStart = location == '/start';
  final atPublic = publicPaths.contains(location);

  return switch (status) {
    // 토큰 확인 중 또는 확인 실패(재시도 버튼): 스플래시 화면 유지
    AuthStatus.initializing ||
    AuthStatus.retryRequired =>
      atStart ? null : '/start',
    // 로그아웃 또는 로그인 요청 중: 공개 화면(로그인·회원가입)만 허용
    AuthStatus.signedOut ||
    AuthStatus.authenticating =>
      atPublic ? null : '/login',
    // 로그인됨: 스플래시와 로그인·회원가입 화면은 홈으로 보냄
    AuthStatus.signedIn => (atStart || atPublic) ? '/home' : null,
  };
}

class AppRouter {
  AppRouter._();

  // 하단 탭(ShellRoute) 위가 아니라 최상위 Navigator에 띄우기 위한 key
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/start',
      refreshListenable: authViewModel, // 인증 상태가 바뀌면 redirect를 다시 실행합니다.
      redirect: (context, state) {
        return authRedirect(authViewModel.status, state.uri.path);
      },
      routes: [
        // 스플래시: 토큰 확인 중 / 확인 실패 시 재시도
        GoRoute(
          path: '/start',
          builder: (context, state) {
            final auth = context.watch<AuthViewModel>();
            return SplashScreen(
              message: auth.message,
              onRetry: auth.status == AuthStatus.retryRequired
                  ? auth.restoreSession
                  : null,
            );
          },
        ),

        // 로그인 화면 (새로 추가)
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),

        // 회원가입 화면 (기존 그대로)
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
                // 로그인 여부는 authRedirect가 이미 보장합니다.
                // MyRatingsViewModel은 앱 전체 Provider(movie_log_app.dart)에서 가져옵니다.
                GoRoute(
                  path: 'ratings',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) => const MyRatingsScreen(),
                ),

                // 프로필 수정 (하단 탭 없이 root Navigator에 표시)
                GoRoute(
                  path: 'profile/edit',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final auth = context.watch<AuthViewModel>();
                    if (auth.member == null) {
                      return Scaffold(
                        appBar: AppBar(
                          centerTitle: true,
                          title: const Text('프로필 수정'),
                        ),
                        body: Center(
                          child: auth.memberStatus == MemberLoadStatus.error
                              ? MovieLogButton(
                                  label: '다시 시도',
                                  onPressed: () =>
                                      auth.loadMember(force: true),
                                )
                              : const CircularProgressIndicator(),
                        ),
                      );
                    }
                    return ChangeNotifierProvider<EditProfileViewModel>(
                      create: (context) => EditProfileViewModel(
                        context.read<MemberApiService>(),
                        auth,
                      ),
                      child: const EditProfileScreen(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        // 영화 상세 화면: URL의 id를 기준으로 하고, extra는 있으면 재사용 (기존 그대로)
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
              initialMovie:
                  extra is TmdbMovieDto && extra.id == id ? extra : null,
            );
          },
        ),
      ],
    );
  }

  // 하단 탭 인덱스
  static int _indexFromLocation(String path) {
    if (path.startsWith('/movies')) return 1;
    if (path.startsWith('/my')) return 2;
    return 0;
  }
}