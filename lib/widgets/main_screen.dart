import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key,
    required this.currentIndex,
    required this.child,
  });

  final int currentIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 12, left: 16, right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFBFC),
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(
              context,
              index: 0,
              unselectedIcon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: '홈',
              route: '/home',
            ),
            _buildTabItem(
              context,
              index: 1,
              unselectedIcon: Icons.movie_creation_outlined,
              selectedIcon: Icons.movie_creation,
              label: '영화',
              route: '/movies',
            ),
            _buildTabItem(
              context,
              index: 2,
              unselectedIcon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: '마이',
              route: '/my',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context, {
    required int index,
    required IconData unselectedIcon,
    required IconData selectedIcon,
    required String label,
    required String route,
  }) {
    final isSelected = currentIndex == index;
    // 검정색 대신 선택 안했을 때와 완전히 동일한 회색 지정
    final grayColor = Colors.grey.shade600;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.go(route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
        decoration: BoxDecoration(
          // 선택 시 연한 회색 배경 + 완전 둥근 알약 모서리
          color: isSelected ? const Color(0xFFEFEFF2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: grayColor, // 비선택과 동일한 회색
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: grayColor, // 비선택과 동일한 회색
              ),
            ),
          ],
        ),
      ),
    );
  }
}