import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_dto.dart';
import '../data/models/rating_with_movie.dart';
import '../data/services/rating_api_service.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/dialog_button.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/rating_dialog.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  static const Color primaryColor = Color(0xFF6653A5);
  static const Color backgroundColor = Color(0xFFFDFCFA);
  static const Color borderColor = Color(0xFFDAD4E3);
  static const Color textColor = Color(0xFF29252D);
  static const Color subTextColor = Color(0xFF6B6672);
  static const Color lightPurple = Color(0xFFEFEBF7);
  static const Color lightRed = Color(0xFFFBEFEE);
  static const Color darkRed = Color(0xFF8E2A2A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          '내가 등록한 평점',
          style: TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: Consumer<MyRatingsViewModel>(
          builder: (context, vm, _) => IconButton(
            icon: const Icon(Icons.arrow_back, color: textColor),
            // 다중 삭제 중에는 화면 이탈 방지
            onPressed: vm.isDeletingSelected
                ? null
                : () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/my');
                    }
                  },
          ),
        ),
        actions: [
          Consumer<MyRatingsViewModel>(
            builder: (context, vm, _) {
              if (vm.ratings.isEmpty && !vm.isEditMode) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: vm.isDeletingSelected
                    ? null
                    : (vm.isEditMode ? vm.exitEditMode : vm.enterEditMode),
                child: Text(
                  vm.isEditMode ? '취소' : '편집',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<MyRatingsViewModel>(
        builder: (context, vm, _) {
          return PopScope(
            canPop: !vm.isDeletingSelected,
            child: LoadingOverlay(
              isLoading: vm.isDeletingSelected,
              child: _buildContent(context, vm),
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<MyRatingsViewModel>(
        builder: (context, vm, _) {
          if (!vm.isEditMode) return const SizedBox.shrink();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: vm.hasSelection && !vm.isDeletingSelected
                      ? () => _onDeleteSelectedPressed(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFC4BFCC),
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: Text('선택한 ${vm.selectedRatingIds.length}개 삭제'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, MyRatingsViewModel vm) {
    if (vm.status == MyRatingsLoadStatus.loading ||
        vm.status == MyRatingsLoadStatus.idle) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.status == MyRatingsLoadStatus.error) {
      final isRefreshFailure = vm.refreshWarning != null;
      return _buildErrorView(
        vm.refreshWarning ?? vm.message ?? '평점을 불러오지 못했습니다.',
        isRefreshFailure ? '조회만 다시 시도' : '다시 시도',
        () => vm.load(), // GET만 다시 호출. POST/PATCH/DELETE는 보내지 않음
      );
    }

    if (vm.status == MyRatingsLoadStatus.empty) {
      return _buildEmptyView();
    }

    return Column(
      children: [
        if (vm.isEditMode) _buildSelectionBar(vm),
        if (vm.message != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              vm.message!,
              style: const TextStyle(color: subTextColor),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => vm.load(showLoading: false),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: vm.ratings.length,
              itemBuilder: (context, index) {
                return _buildRatingCard(context, vm.ratings[index], vm);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionBar(MyRatingsViewModel vm) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '${vm.selectedRatingIds.length}개 선택',
            style: const TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: vm.selectAll,
            child: Text(
              vm.isAllSelected ? '전체 해제' : '전체 선택',
              style: const TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard(
    BuildContext context,
    RatingWithMovie item,
    MyRatingsViewModel vm,
  ) {
    final rating = item.rating;
    final movie = item.movie;
    final selected = vm.selectedRatingIds.contains(rating.ratingId);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (vm.isEditMode)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Checkbox(
                value: selected,
                activeColor: primaryColor,
                onChanged: (_) => vm.toggleSelection(rating.ratingId),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: movie?.posterPath != null
                ? Image.network(
                    'https://image.tmdb.org/t/p/w500${movie!.posterPath}',
                    width: 92,
                    height: 138,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _buildPosterPlaceholder(),
                  )
                : _buildPosterPlaceholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // 영화 정보를 못 가져오면 "영화 #번호"로 표시
                  movie?.title ?? '영화 #${rating.movieId}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '별점 ${rating.score} / 5',
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (rating.comment != null && rating.comment!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    rating.comment!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: subTextColor,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 편집 모드에서는 개별 수정/삭제 버튼 대신 체크박스만 보여줍니다.
          if (!vm.isEditMode) ...[
            const SizedBox(width: 8),
            Column(
              children: [
                _SmallActionButton(
                  label: '수정',
                  backgroundColor: lightPurple,
                  textColor: primaryColor,
                  onPressed: () => _onEditPressed(context, rating),
                ),
                const SizedBox(height: 8),
                _SmallActionButton(
                  label: '삭제',
                  backgroundColor: lightRed,
                  textColor: darkRed,
                  onPressed: () => _onDeletePressed(context, rating.ratingId),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ───────── 수정 ─────────

  Future<void> _onEditPressed(BuildContext context, RatingDto rating) async {
    final vm = context.read<MyRatingsViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 저장 중 바깥 탭 방지
      builder: (_) => RatingDialog(
        initialScore: rating.score,
        initialComment: rating.comment, // null이면 TextField는 빈 칸으로 시작
        onSubmit: (score, comment) async {
          try {
            await vm.updateRating(
              ratingId: rating.ratingId,
              score: score,
              comment: comment,
            );
          } on DioException catch (error) {
            // 400/403/404 서버 문구를 Dialog 안에 표시
            throw StateError(writeErrorMessage(error));
          }
        },
      ),
    );

    if (saved != true) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('평점을 수정했습니다.')),
    );
  }

  // ───────── 단일 삭제 (삭제되는 동안 Dialog 유지) ─────────

  Future<void> _onDeletePressed(BuildContext context, int ratingId) async {
    final vm = context.read<MyRatingsViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DeleteRatingDialog(
        onConfirm: () async {
          try {
            await vm.deleteRating(ratingId);
          } on DioException catch (error) {
            throw StateError(writeErrorMessage(error));
          }
        },
      ),
    );

    if (deleted != true) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('평점을 삭제했습니다.')),
    );
  }

  // ───────── 다중 삭제 (확인 Dialog는 바로 닫고, 이후 오버레이 표시) ─────────

  Future<void> _onDeleteSelectedPressed(BuildContext context) async {
    final vm = context.read<MyRatingsViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final count = vm.selectedRatingIds.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDeleteDialog(
        title: '선택한 평점을 삭제할까요?',
        message: '$count개의 평점이 삭제되며 복구할 수 없습니다.',
      ),
    );
    // Dialog는 여기서 이미 닫혔습니다. 이후 삭제는 화면 오버레이가 담당합니다.

    if (confirmed != true) return;

    final failed = await vm.deleteSelectedRatings();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          failed > 0
              ? '$failed개 항목을 삭제하지 못했습니다. 선택된 항목을 다시 확인해 주세요.'
              : '선택한 평점을 삭제했습니다.',
        ),
      ),
    );
  }

  // ───────── 공통 UI ─────────

  Widget _buildPosterPlaceholder() {
    return Container(
      width: 92,
      height: 138,
      color: const Color(0xFFD8D4E3),
    );
  }

  Widget _buildErrorView(
    String message,
    String buttonLabel,
    VoidCallback onRetry,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Text(
        '아직 등록한 평점이 없습니다.',
        style: TextStyle(color: subTextColor),
      ),
    );
  }
}

// 카드 오른쪽의 작은 수정/삭제 버튼
class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 38,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// 삭제 Dialog 공통 틀 (3번 사진)
class _DeleteDialogFrame extends StatelessWidget {
  const _DeleteDialogFrame({
    required this.title,
    required this.message,
    required this.errorText,
    required this.buttons,
  });

  final String title;
  final String message;
  final String? errorText;
  final Widget buttons;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: MyRatingsScreen.textColor,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: MyRatingsScreen.subTextColor,
                ),
              ),
              if (errorText != null) ...[
                const SizedBox(height: 10),
                Text(
                  errorText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              buttons,
            ],
          ),
        ),
      ),
    );
  }
}

// 단일 삭제: 삭제 요청 중에도 Dialog 유지
class _DeleteRatingDialog extends StatefulWidget {
  const _DeleteRatingDialog({required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  State<_DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<_DeleteRatingDialog> {
  bool _isDeleting = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: _DeleteDialogFrame(
        title: '평점을 삭제할까요?',
        message: '삭제한 평점은 복구할 수 없습니다.',
        errorText: _errorText,
        buttons: Row(
          children: [
            Expanded(
              child: DialogButton(
                label: '취소',
                height: 50,
                radius: 10,
                onPressed:
                    _isDeleting ? null : () => Navigator.pop(context, false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DialogButton(
                label: '삭제',
                height: 50,
                radius: 10,
                isPrimary: true,
                isLoading: _isDeleting,
                onPressed: _isDeleting ? null : _onConfirm,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() {
      _isDeleting = true;
      _errorText = null;
    });
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _errorText = error is StateError
            ? error.message
            : '삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.';
      });
    }
  }
}

// 다중 삭제: 확인만 받고 바로 닫힘 (이후 화면 오버레이가 진행 표시)
class _ConfirmDeleteDialog extends StatelessWidget {
  const _ConfirmDeleteDialog({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _DeleteDialogFrame(
      title: title,
      message: message,
      errorText: null,
      buttons: Row(
        children: [
          Expanded(
            child: DialogButton(
              label: '취소',
              height: 50,
              radius: 10,
              onPressed: () => Navigator.pop(context, false),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DialogButton(
              label: '삭제',
              height: 50,
              radius: 10,
              isPrimary: true,
              onPressed: () => Navigator.pop(context, true),
            ),
          ),
        ],
      ),
    );
  }
}