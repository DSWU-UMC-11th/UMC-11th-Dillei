import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/session/session_guard.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../data/services/favorite_api_service.dart';
import '../data/services/member_api_service.dart';
import '../data/services/sign_up_service.dart';
import '../data/services/tmdb_movie_service.dart';

import '../screens/edit_profile_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/movie_detail_loader.dart';
import '../screens/movie_list_screen.dart';
import '../screens/movie_search_screen.dart';
import '../screens/my_ratings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';

import '../widgets/main_screen.dart';
import '../widgets/movielog_button.dart';

import '../view_models/auth_view_model.dart';
import '../view_models/edit_profile_view_model.dart';
import '../view_models/favorite_detail_view_model.dart';
import '../view_models/favorites_view_model.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/paged_movies_view_model.dart';
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

        // 로그인 화면
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
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
            // 홈 (인기 영화 5개 API는 그대로입니다)
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

            // 영화 목록: 더 보기(페이지네이션)
            GoRoute(
              path: '/movies',
              builder: (context, state) {
                return ChangeNotifierProvider<PagedMoviesViewModel>(
                  create: (context) => PagedMoviesViewModel(
                    tmdbApi: context.read<TmdbMovieService>(),
                  )
                    ..loadGenres()
                    ..loadInitial(),
                  child: const MovieListScreen(),
                );
              },
              routes: [
                // 영화 검색 (하단 탭 없이 root Navigator에 표시)
                // 영화 목록과 별도의 PagedMoviesViewModel 인스턴스를 사용합니다.
                GoRoute(
                  path: 'search',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    return ChangeNotifierProvider<PagedMoviesViewModel>(
                      create: (context) => PagedMoviesViewModel(
                        tmdbApi: context.read<TmdbMovieService>(),
                      ),
                      child: MovieSearchScreen(
                        onOpenMovie: (movie) async {
                          await context.push(
                            '/movies/${movie.id}',
                            extra: movie,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
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
                  builder: (context, state) => const MyRatingsScreen(),
                ),

                // 내 즐겨찾기 (하단 탭 없이 root Navigator에 표시)
                GoRoute(
                  path: 'favorites',
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final auth = context.watch<AuthViewModel>();
                    final member = auth.member;
                    final guard = context.read<SessionGuard>();

                    // 내 정보가 아직 없으면 로딩 또는 다시 시도 버튼
                    if (member == null) {
                      return Scaffold(
                        appBar: AppBar(
                          centerTitle: true,
                          title: const Text('내 즐겨찾기'),
                        ),
                        body: Center(
                          child: auth.memberStatus == MemberLoadStatus.error
                              ? MovieLogButton(
                                  label: '내 정보 다시 조회',
                                  onPressed: () =>
                                      auth.loadMember(force: true),
                                )
                              : const CircularProgressIndicator(),
                        ),
                      );
                    }

                    // 현재 세션과 계정이 일치할 때까지 기다립니다.
                    if (guard.accountId != member.email) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    return ChangeNotifierProvider<FavoritesViewModel>(
                      // 계정이나 세션이 바뀌면 이전 사용자의 ViewModel을 버립니다.
                      key: ValueKey('${member.email}:${guard.generation}'),
                      create: (context) => FavoritesViewModel(
                        favoriteApi: context.read<FavoriteApiService>(),
                        tmdbApi: context.read<TmdbMovieService>(),
                        sessionGuard: guard,
                        accountId: member.email,
                      ),
                      child: FavoritesScreen(
                        onOpenMovie: (movie) async {
                          await context.push(
                            '/movies/${movie.id}',
                            extra: movie,
                          );
                        },
                      ),
                    );
                  },
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

        // 영화 상세 화면: URL의 id를 기준으로 하고, extra는 있으면 재사용합니다.
        // 즐겨찾기 ViewModel을 MovieDetailLoader 바깥에서 제공합니다.
        GoRoute(
          path: '/movies/:movieId',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['movieId'] ?? '');
            if (id == null || id < 1) {
              return const Scaffold(
                body: Center(child: Text('영화 ID가 올바르지 않습니다.')),
              );
            }

            // 내 정보가 준비되고 현재 세션과 일치할 때까지 로딩을 보여 줍니다.
            final member = context.watch<AuthViewModel>().member;
            final guard = context.read<SessionGuard>();
            if (member == null || guard.accountId != member.email) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final extra = state.extra;
            return ChangeNotifierProvider<FavoriteDetailViewModel>(
              key: ValueKey('${member.email}:${guard.generation}:$id'),
              create: (context) => FavoriteDetailViewModel(
                movieId: id,
                favoriteApi: context.read<FavoriteApiService>(),
                sessionGuard: guard,
                accountId: member.email,
              ),
              child: MovieDetailLoader(
                movieId: id,
                initialMovie:
                    extra is TmdbMovieDto && extra.id == id ? extra : null,
              ),
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