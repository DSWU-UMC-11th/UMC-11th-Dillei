import 'package:flutter/material.dart';

class DialogButton extends StatelessWidget {
  const DialogButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isLoading = false,
    this.radius = 14,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final double radius;
  final double height;

  static const Color primaryColor = Color(0xFF6653A5);
  static const Color lightColor = Color(0xFFEFEBF7);
  static const Color disabledColor = Color(0xFFC4BFCC);

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || onPressed == null;

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isPrimary ? primaryColor : lightColor,
          foregroundColor: isPrimary ? Colors.white : primaryColor,
          // 확인 버튼이 비활성(별점 미선택/저장 중)이면 회색
          disabledBackgroundColor: isPrimary ? disabledColor : lightColor,
          disabledForegroundColor:
              isPrimary ? Colors.white : primaryColor.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}