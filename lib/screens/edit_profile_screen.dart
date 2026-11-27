import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view_models/auth_view_model.dart';
import '../view_models/edit_profile_view_model.dart';
import '../widgets/movielog_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _controller;
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    final member = context.read<AuthViewModel>().member;
    _controller = TextEditingController(text: member?.nickname ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 현재 서버 닉네임과 입력값이 다르면 변경 내용이 있는 것으로 봅니다.
  bool get _dirty {
    final current = context.read<AuthViewModel>().member?.nickname ?? '';
    return _controller.text.trim() != current;
  }

  // PopScope의 canPop은 build 때 반영되므로 setState 뒤 다음 프레임에 pop 합니다.
  void _leave() {
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  Future<void> _confirmDiscard() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('변경 사항이 있어요'),
        content: const Text('저장하지 않고 나갈까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('확인'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) _leave(); // 확인 → 마이페이지, 취소 → 현재 화면 유지
  }

  Future<void> _submit() async {
    final viewModel = context.read<EditProfileViewModel>();
    final messenger = ScaffoldMessenger.of(context);

    final success = await viewModel.save(_controller.text);
    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(const SnackBar(content: Text('프로필을 수정했어요.')));
      _leave(); // 마이페이지에는 이미 새 닉네임이 반영되어 있습니다.
    } else if (viewModel.message != null) {
      messenger.showSnackBar(SnackBar(content: Text(viewModel.message!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final email =
        context.select<AuthViewModel, String?>((a) => a.member?.email);

    return Consumer<EditProfileViewModel>(
      builder: (context, viewModel, child) {
        final saving = viewModel.status == EditProfileStatus.saving;

        return PopScope(
          canPop: _allowPop || (!saving && !_dirty),
          onPopInvokedWithResult: (didPop, result) {
            if (didPop || saving) return; // 저장 중에는 나가지 못합니다.
            _confirmDiscard();
          },
          child: Scaffold(
            appBar: AppBar(centerTitle: true, title: const Text('프로필 수정')),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: email,
                    enabled: false, // email은 읽기 전용입니다.
                    decoration: const InputDecoration(labelText: '이메일'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    enabled: !saving,
                    maxLength: 12,
                    onChanged: (_) => setState(() {}), // 변경 여부(_dirty) 갱신
                    decoration: InputDecoration(
                      labelText: '닉네임',
                      errorText: viewModel.nicknameError,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: MovieLogButton(
                      label: '저장',
                      isLoading: saving,
                      onPressed: saving ? null : _submit,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}