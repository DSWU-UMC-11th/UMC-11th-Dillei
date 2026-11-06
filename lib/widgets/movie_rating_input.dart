import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../theme/app_colors.dart';

class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
    this.enabled = true,
  });

  final double rating;
  final ValueChanged<double> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return RatingBar(
      initialRating: rating,
      minRating: 1,
      allowHalfRating: false, // 서버는 1~5 정수만 받음
      ignoreGestures: !enabled,
      glow: false,
      itemCount: 5,
      itemSize: 44,
      itemPadding: const EdgeInsets.symmetric(horizontal: 3),
      ratingWidget: RatingWidget(
        full: const Icon(Icons.star, color: AppColors.violet),
        half: const Icon(Icons.star_half, color: AppColors.violet),
        empty: const Icon(Icons.star_border, color: AppColors.violet),
      ),
      onRatingUpdate: onChanged,
    );
  }
}