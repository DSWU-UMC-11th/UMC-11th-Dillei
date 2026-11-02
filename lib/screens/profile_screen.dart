
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/stat_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CommonAppBar(
        title: '내 프로필',
        centerTitle: false,
        titleStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.violet,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                ProfileHeader(
                  imagePath: 'assets/images/profile.jpg',
                ),
                SizedBox(height: 28),
                ProfileStatsSection(),
                SizedBox(height: 32),
                FavoriteGenresSection(),
                SizedBox(height: 32),
                MyRatingsMenuSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ==========================================
// 1. 프로필 상단 영역
// ==========================================

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    this.imagePath,
  });

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),

        CircleAvatar(
          radius: 48,
          backgroundColor: AppColors.lavender,
          child: CircleAvatar(
            radius: 46,
            backgroundColor: AppColors.lightGray,
            backgroundImage: imagePath != null
                ? AssetImage(imagePath!)
                : null,
            child: imagePath == null
                ? const Icon(
                    Icons.person,
                    size: 48,
                    color: AppColors.gray,
                  )
                : null,
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          '무비러버',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          '매주 주말엔 영화관으로 출근하는 프로 관람객.\n'
          '좋은 영화를 보고 기록하는 것을 좋아합니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.black,
            height: 1.45,
          ),
        ),

        const SizedBox(height: 16),

        TextButton(
          onPressed: () {
            // 프로필 수정 기능 연결 예정
          },
          style: TextButton.styleFrom(
            side: BorderSide(
              color: AppColors.violet.withValues(alpha: 0.6),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 8,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            '프로필 수정',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.violet,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}


// ==========================================
// 2. 프로필 통계 영역
// ==========================================

class ProfileStatsSection extends StatelessWidget {
  const ProfileStatsSection({super.key});

  @override
  Widget build(BuildContext context) {

    // 통계 데이터
    final List<Map<String, String>> stats = [
      {
        'label': '본 영화',
        'value': '342',
      },
      {
        'label': '평점',
        'value': '4.2',
      },
      {
        'label': '즐겨찾기',
        'value': '58',
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: stats.map((stat) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
            ),
            child: StatItem(
              label: stat['label']!,
              value: stat['value']!,
            ),
          ),
        );
      }).toList(),
    );
  }
}


// ==========================================
// 3. 선호 장르 영역
// ==========================================

class FavoriteGenresSection extends StatelessWidget {
  const FavoriteGenresSection({super.key});

  static const List<String> _genres = [
    '드라마',
    'SF',
    '애니메이션',
  ];

  // 선호 장르 상세 BottomSheet
  void _showGenreBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '선호 장르 상세',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),

              const SizedBox(height: 16),

              const ListTile(
                leading: Icon(
                  Icons.movie_filter,
                  color: AppColors.violet,
                ),
                title: Text('드라마'),
              ),

              const ListTile(
                leading: Icon(
                  Icons.rocket_launch,
                  color: AppColors.violet,
                ),
                title: Text('SF'),
              ),

              const ListTile(
                leading: Icon(
                  Icons.animation,
                  color: AppColors.violet,
                ),
                title: Text('애니메이션'),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violet,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(sheetContext);
                  },
                  child: const Text(
                    '닫기',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // 제목 및 자세히 보기
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '선호하는 장르',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),

            GestureDetector(
              onTap: () {
                _showGenreBottomSheet(context);
              },
              child: const Text(
                '자세히 보기',
                style: TextStyle(
                  color: AppColors.violet,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 장르 Chip
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _genres.map((genre) {
            return Chip(
              label: Text(
                genre,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.violet,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppColors.lavender,
              side: BorderSide.none,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
            );
          }).toList(),
        ),
      ],
    );
  }
}


// ==========================================
// 4. 내가 등록한 평점 메뉴
// ==========================================

class MyRatingsMenuSection extends StatelessWidget {
  const MyRatingsMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lavender.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.star_rate_rounded,
          color: AppColors.violet,
        ),

        title: const Text(
          '내가 등록한 평점',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),

        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.gray,
        ),

        onTap: () {
          context.push('/my/ratings');
        },
      ),
    );
  }
}
