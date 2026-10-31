import 'package:flutter/material.dart';
// import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
    this.centerTitle = true,
    this.titleStyle,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool centerTitle;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: titleStyle ?? AppTextStyles.titleLarge,
      ),
      centerTitle: centerTitle,
      leading: onBack != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}