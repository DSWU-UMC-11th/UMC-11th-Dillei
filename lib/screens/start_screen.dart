import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'FLUTTER 1주차',
                    style: AppTextStyles.bodySmall.copyWith(letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 56),
                  // 1. 기본 아이콘
                  //const Icon(
                  //  Icons.movie_outlined,
                  //  size: 80,
                  //  color: AppColors.violet,
                  //),

                  // 2. SVG 로고 
                  // SvgPicture.asset(
                  //   'assets/logos/movielog_logo.svg',
                  //   width: 80,
                  //   height: 80,
                  // ),

                  // 3. PNG 로고 
                  Image.asset(
                    'assets/logos/movielog_logo.png',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '영화의 순간을\n기록하세요',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.violet,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '시작하기',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
