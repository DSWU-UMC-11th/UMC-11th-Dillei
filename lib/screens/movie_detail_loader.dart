import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import '../view_models/learning_member_session.dart';
import '../view_models/movie_detail_view_model.dart';
import 'movie_detail_screen.dart';

class MovieDetailLoader extends StatefulWidget {
  const MovieDetailLoader({
    super.key,
    required this.movieId,
    this.initialMovie,
  });

  final int movieId;
  final TmdbMovieDto? initialMovie;

  @override
  State<MovieDetailLoader> createState() => _MovieDetailLoaderState();
}

class _MovieDetailLoaderState extends State<MovieDetailLoader> {
  late final Future<TmdbMovieDto?> _movieFuture;

  @override
  void initState() {
    super.initState();
    _movieFuture = widget.initialMovie != null
        ? Future.value(widget.initialMovie)
        : context.read<TmdbMovieService>().findMovieById(widget.movieId);
  }

  Widget _errorScaffold() {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      body: const Center(child: Text('영화를 불러오지 못했습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TmdbMovieDto?>(
      future: _movieFuture, // build마다 새 Future를 만들지 않습니다.
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final movie = snapshot.data;
        if (snapshot.hasError || movie == null) {
          return _errorScaffold();
        }
        return ChangeNotifierProvider<MovieDetailViewModel>(
          create: (context) => MovieDetailViewModel(
            context.read<RatingApiService>(),
            context.read<LearningMemberSession>(),
          ),
          child: MovieDetailScreen(movie: movie),
        );
      },
    );
  }
}