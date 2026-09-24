import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/stat_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmWhite,
      appBar: const CommonAppBar(
        title: '내 프로필',
        centerTitle: false,
        titleStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.violet,
        ),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHeader(
                  imagePath: 'assets/images/profile.jpg',
                ),
                SizedBox(height: 28),
                ProfileStatsSection(),
                SizedBox(height: 32),
                FavoriteGenresSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 1. 프로필 헤더 (연보라 밀착 테두리 + TextButton 적용)
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, this.imagePath});

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
            backgroundImage: imagePath != null ? AssetImage(imagePath!) : null,
            child: imagePath == null
                ? const Icon(Icons.person, size: 48, color: AppColors.gray)
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
          '매주 주말엔 영화관으로 출근하는 프로 관람객. 좋\n은 영화를 보고 기록하는 것을 좋아합니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.black,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            side: BorderSide(
              color: AppColors.violet.withValues(alpha: 0.6),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
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

// 2. 통계 섹션
class ProfileStatsSection extends StatelessWidget {
  const ProfileStatsSection({super.key});

  static const List<Map<String, String>> _stats = [
    {'label': '본 영화', 'value': '342'},
    {'label': '평점', 'value': '4.2'},
    {'label': '즐겨찾기', 'value': '58'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _stats
          .map(
            (stat) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: StatItem(
                  label: stat['label']!,
                  value: stat['value']!,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// 3. 선호 장르 섹션 (BottomSheet 연동 포함)
class FavoriteGenresSection extends StatelessWidget {
  const FavoriteGenresSection({super.key});

  static const List<String> _genres = ['드라마', 'SF', '애니메이션'];

  // BottomSheet 호출 함수 (3주차 필수 요구사항)
  void _showGenreBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                leading: Icon(Icons.movie_filter, color: AppColors.violet),
                title: Text('드라마'),
              ),
              const ListTile(
                leading: Icon(Icons.rocket_launch, color: AppColors.violet),
                title: Text('SF'),
              ),
              const ListTile(
                leading: Icon(Icons.animation, color: AppColors.violet),
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
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text(
                    '닫기',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
              onTap: () => _showGenreBottomSheet(context),
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _genres
              .map(
                (genre) => Chip(
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}