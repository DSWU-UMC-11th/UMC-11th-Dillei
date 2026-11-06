import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/network/tmdb_client.dart';
import '../core/network/movie_log_client.dart'; // 워크북 백엔드 클라이언트
import '../data/services/tmdb_movie_service.dart';
import '../data/services/sign_up_service.dart';
import '../data/services/rating_api_service.dart'; // 평점 조회 서비스
import '../router/app_router.dart';
import '../view_models/learning_member_session.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 워크북 백엔드 전용 Dio 클라이언트 생성 (두 서비스가 하나를 공유)
    final movieLogClient = createMovieLogClient();

    return MultiProvider(
      providers: [
        // TMDB 영화 서비스
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
        // 6주차: 회원가입 서비스
        Provider<SignUpService>(
          create: (_) => SignUpService(movieLogClient),
        ),
        // 6주차: 유저 평점 조회 서비스
        Provider<RatingApiService>(
          create: (_) => RatingApiService(movieLogClient),
        ),
        ChangeNotifierProvider<LearningMemberSession>(
  create: (_) => LearningMemberSession(),
  ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'MovieLog',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.white,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}