import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. provider 패키지 임포트 추가
import '../../core/network/tmdb_client.dart'; // 경로에 맞게 확인
import '../../data/services/tmdb_movie_service.dart'; // 경로에 맞게 확인
import '../../router/app_router.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. MultiProvider로 감싸줍니다.
    return MultiProvider(
      providers: [
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
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