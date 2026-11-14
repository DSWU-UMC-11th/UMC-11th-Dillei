import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/storage/token_storage.dart';
import '../data/models/member_info.dart';
import '../theme/app_colors.dart';
import '../view_models/auth_view_model.dart';
import '../widgets/movielog_button.dart';
import '../widgets/stat_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // read가 아니라 watch: member·memberStatus가 바뀌면 화면이 다시 그려집니다.
    final auth = context.watch<AuthViewModel>();
    final member = auth.member;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          '내 프로필',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.violet,
          ),
        ),
        actions: [
          IconButton(
            tooltip: '로그아웃',
            icon: const Icon(Icons.logout, color: AppColors.violet),
            // 이동은 직접 하지 않습니다. signedOut이 되면 Router가 /login으로 보냅니다.
            onPressed: auth.storageCleanupInProgress
                ? null
                : () => context.read<AuthViewModel>().logout(),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(context, auth, member)),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AuthViewModel auth,
    MemberInfo? member,
  ) {
    // 내 정보 로딩·실패·재시도 (Challenge)
    if (member == null) {
      if (auth.memberStatus == MemberLoadStatus.error) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  auth.message ?? '내 정보를 불러오지 못했어요.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                MovieLogButton(
                  label: '다시 시도',
                  onPressed: () => auth.loadMember(force: true),
                ),
              ],
            ),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileHeader(
              imagePath: 'assets/images/profile.jpg',
              member: member,
            ),
            const SizedBox(height: 28),
            const ProfileStatsSection(),
            const SizedBox(height: 32),
            const FavoriteGenresSection(),
            const SizedBox(height: 32),
            const MyRatingsMenuSection(),

            // 검증용: 무효 토큰을 저장한 뒤 앱을 재시작하면 만료 흐름을 재현할 수 있습니다.
            // 인증 증거를 다 찍은 뒤 이 블록을 지우세요.
            if (kDebugMode) ...[
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => context
                    .read<TokenStorage>()
                    .saveAccessToken('invalid.token.value'),
                child: const Text('[디버그] 무효 토큰 저장'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


// ==========================================
// 1. 프로필 상단 영역
// ==========================================

String _joinedText(DateTime createdAt) {
  final d = createdAt.toLocal();
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}.$mm.$dd 가입'; // 예: 2026.10.10 가입 (Challenge)
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.member,
    this.imagePath,
  });

  final MemberInfo member;
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

        // 서버에서 받은 내 닉네임
        Text(
          member.nickname,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),

        const SizedBox(height: 4),

        // 닉네임 아래 가입일 (Challenge)
        Text(
          _joinedText(member.createdAt),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.gray,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          member.email,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.gray,
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
          onPressed: () => context.push('/my/profile/edit'),
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