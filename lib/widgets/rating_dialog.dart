import 'package:flutter/material.dart';

import '../data/models/rating_request.dart';
import 'dialog_button.dart';
import 'movie_rating_input.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({
    super.key,
    this.initialScore = 0,
    this.initialComment,
    required this.onSubmit,
  });

  final int initialScore;
  final String? initialComment;
  final Future<void> Function(int score, String? comment) onSubmit;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  static const Color _textColor = Color(0xFF29252D);
  static const Color _borderColor = Color(0xFFDAD4E3);
  static const Color _fillColor = Color(0xFFFAF8FD);
  static const Color _primaryColor = Color(0xFF6653A5);

  late int _score = widget.initialScore;
  late final _commentController =
      TextEditingController(text: widget.initialComment ?? '');
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color, {double width = 1.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '평점을 남겨주세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: MovieRatingInput(
                    rating: _score.toDouble(),
                    enabled: !_isSubmitting,
                    onChanged: (value) =>
                        setState(() => _score = validateServerScore(value)),
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  '코멘트 (선택, 최대 500자)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4A4550),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _commentController,
                  minLines: 4,
                  maxLines: 4,
                  maxLength: 500,
                  enabled: !_isSubmitting,
                  style: const TextStyle(fontSize: 14, color: _textColor),
                  decoration: InputDecoration(
                    counterText: '', // 글자 수 표시는 숨기고 500자 제한만 유지
                    hintText: '이 영화의 인상적인 장면은...',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8D8794),
                    ),
                    filled: true,
                    fillColor: _fillColor,
                    contentPadding: const EdgeInsets.all(16),
                    enabledBorder: _border(_borderColor),
                    disabledBorder: _border(_borderColor),
                    focusedBorder: _border(_primaryColor),
                  ),
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _errorText!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: DialogButton(
                        label: '취소',
                        radius: 26,
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context, false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DialogButton(
                        label: '확인',
                        isPrimary: true,
                        radius: 26,
                        isLoading: _isSubmitting,
                        onPressed:
                            _score > 0 && !_isSubmitting ? _onConfirm : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onConfirm() async {
    final trimmed = _commentController.text.trim();
    if (trimmed.length > 500) {
      setState(() => _errorText = '코멘트는 500자 이하로 입력해 주세요.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await widget.onSubmit(_score, trimmed.isEmpty ? null : trimmed);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false; // 실패해도 버튼 로딩을 반드시 해제, 입력값은 유지
        _errorText = error is StateError
            ? error.message
            : '저장하지 못했습니다. 잠시 후 다시 시도해 주세요.';
      });
    }
  }
}