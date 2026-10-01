import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/terms_checkbox.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _agreedToTerms = false;

  String? _nicknameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // 각 필드별 유효 여부 판별
  bool get _isNicknameValid =>
      _nicknameController.text.trim().length >= 2 && _nicknameError == null;

  bool get _isEmailValid {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(_emailController.text.trim()) && _emailError == null;
  }

  bool get _isPasswordValid =>
      _passwordController.text.length >= 8 && _passwordError == null;

  void _validateNickname(String value) {
    final text = value.trim();
    setState(() {
      if (text.isEmpty) {
        _nicknameError = null;
      } else if (text.length < 2) {
        _nicknameError = '닉네임은 2자 이상이어야 합니다.';
      } else {
        _nicknameError = null;
      }
    });
  }

  void _validateEmail(String value) {
    final text = value.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      if (text.isEmpty) {
        _emailError = null;
      } else if (!emailRegex.hasMatch(text)) {
        _emailError = '올바른 이메일 형식이 아닙니다.';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = null;
      } else if (value.length < 8) {
        _passwordError = '비밀번호는 8자 이상이어야 합니다.';
      } else {
        _passwordError = null;
      }
    });
  }

  bool get _canSubmit =>
      _isNicknameValid && _isEmailValid && _isPasswordValid && _agreedToTerms;

  void _submit() {
    if (_canSubmit) {
      FocusScope.of(context).unfocus();
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFBFC),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5B4FA9)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            color: Color(0xFF5B4FA9),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxFormWidth = constraints.maxWidth >= 700 ? 560.0 : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxFormWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),
                          const Text(
                            '환영합니다!\n간단한 정보만 입력하고 시작해보세요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 닉네임 입력
                          CustomTextField(
                            controller: _nicknameController,
                            label: '닉네임',
                            hint: '닉네임을 입력해주세요',
                            errorText: _nicknameError,
                            isValid: _isNicknameValid,
                            textInputAction: TextInputAction.next,
                            onChanged: _validateNickname,
                            onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
                          ),
                          const SizedBox(height: 18),

                          // 이메일 입력
                          CustomTextField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            label: '이메일',
                            hint: '이메일 주소를 입력해주세요',
                            errorText: _emailError,
                            isValid: _isEmailValid,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onChanged: _validateEmail,
                            onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                          ),
                          const SizedBox(height: 18),

                          // 비밀번호 입력
                          CustomTextField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            label: '비밀번호',
                            hint: '비밀번호를 입력해주세요',
                            obscureText: true,
                            errorText: _passwordError,
                            isValid: _isPasswordValid,
                            textInputAction: TextInputAction.done,
                            onChanged: _validatePassword,
                            onFieldSubmitted: (_) {
                              if (_canSubmit) _submit();
                            },
                          ),

                          const Spacer(),
                          const SizedBox(height: 24),

                          // 약관 동의 체크박스
                          TermsCheckbox(
                            value: _agreedToTerms,
                            onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                          ),
                          const SizedBox(height: 16),

                          // 가입하기 버튼
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _canSubmit ? _submit : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5B4FA9),
                                disabledBackgroundColor: const Color(0xFFC7C3E1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                '가입하기',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 로그인 링크
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '이미 계정이 있나요? ',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  '로그인',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5B4FA9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}