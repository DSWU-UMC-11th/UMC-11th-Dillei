import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view_models/sign_up_view_model.dart';
import '../widgets/movielog_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 색상
  static const Color primaryColor = Color(0xFF6653A5);
  static const Color backgroundColor = Color(0xFFFBFAF8);
  static const Color borderColor = Color(0xFFD9D3E3);
  static const Color successColor = Color(0xFF548B49);
  static const Color errorColor = Color(0xFFE05252);
  static const Color infoColor = Color(0xFF4777D5);

  // 입력 컨트롤러
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // 닉네임 형식 상태 (서버 중복 확인 상태는 SignUpViewModel이 관리)
  bool _isNicknameFormatValid = false;
  String? _nicknameFormatMessage;

  // 이메일 형식 상태 (서버 중복 확인 상태는 SignUpViewModel이 관리)
  bool _isEmailFormatValid = false;
  String? _emailFormatMessage;

  // 비밀번호 상태
  bool _isPasswordValid = false;
  String? _passwordMessage;

  // 약관 동의
  bool _agreedToTerms = false;

  // 정규식
  final RegExp _nicknameRegex = RegExp(r'^[가-힣a-zA-Z0-9]{2,10}$');
  final RegExp _emailRegex = RegExp(r'^[\w.+-]+@([\w-]+\.)+[A-Za-z]{2,}$');

  // 전체 가입 가능 여부
  bool _canSubmit(SignUpViewModel vm) {
    return _isNicknameFormatValid &&
        vm.nicknameCheckStatus == CheckStatus.available &&
        _isEmailFormatValid &&
        vm.emailCheckStatus == CheckStatus.available &&
        _isPasswordValid &&
        _agreedToTerms;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  // ==========================================
  // 1. 닉네임 입력 변경 (형식 검사 + 이전 확인 결과 무효화)
  // ==========================================

  void _onNicknameChanged(String value) {
    final nickname = value.trim();

    setState(() {
      _isNicknameFormatValid = _nicknameRegex.hasMatch(nickname);
      _nicknameFormatMessage = (nickname.isEmpty || _isNicknameFormatValid)
          ? null
          : '닉네임은 한글, 영문, 숫자 2~10자로 입력해주세요.';
    });

    context.read<SignUpViewModel>().onNicknameChanged(value);
  }

  // ==========================================
  // 2. 이메일 입력 변경 (형식 검사 + 이전 확인 결과 무효화)
  // ==========================================

  void _onEmailChanged(String value) {
    final email = value.trim();

    setState(() {
      _isEmailFormatValid = _emailRegex.hasMatch(email);
      _emailFormatMessage = (email.isEmpty || _isEmailFormatValid)
          ? null
          : '올바른 이메일 형식이 아닙니다.';
    });

    context.read<SignUpViewModel>().onEmailChanged(value);
  }

  // ==========================================
  // 3. 비밀번호 유효성 검사
  // ==========================================

  void _validatePassword(String value) {
    setState(() {
      _isPasswordValid = value.length >= 8;

      if (value.isEmpty) {
        _passwordMessage = null;
      } else if (value.length < 8) {
        _passwordMessage = '비밀번호는 8자 이상이어야 합니다.';
      } else {
        _passwordMessage = null;
      }
    });
  }

  // ==========================================
  // 4. 회원가입 (6주차: 실제 가입 요청 없이 홈으로 이동)
  // ==========================================

  void _submit() {
    FocusScope.of(context).unfocus();

    context.go('/home');
  }

  // ==========================================
  // 5. 중복 확인 상태 -> 안내 문구/색상/에러 여부
  // ==========================================

  ({String? text, Color color, bool isError}) _nicknameFeedback(
    SignUpViewModel vm,
  ) {
    // 형식 오류가 있으면 그 문구를 우선 표시
    if (_nicknameFormatMessage != null) {
      return (text: _nicknameFormatMessage, color: errorColor, isError: true);
    }

    switch (vm.nicknameCheckStatus) {
      case CheckStatus.checking:
        return (
          text: '닉네임 중복 여부를 확인 중입니다.',
          color: infoColor,
          isError: false,
        );
      case CheckStatus.available:
        return (
          text: '사용 가능한 닉네임입니다.',
          color: successColor,
          isError: false,
        );
      case CheckStatus.duplicated:
      case CheckStatus.error:
        return (text: vm.nicknameErrorText, color: errorColor, isError: true);
      case CheckStatus.idle:
        return (text: null, color: infoColor, isError: false);
    }
  }

  ({String? text, Color color, bool isError}) _emailFeedback(
    SignUpViewModel vm,
  ) {
    if (_emailFormatMessage != null) {
      return (text: _emailFormatMessage, color: errorColor, isError: true);
    }

    switch (vm.emailCheckStatus) {
      case CheckStatus.checking:
        return (
          text: '이메일 사용 가능 여부를 확인 중입니다.',
          color: infoColor,
          isError: false,
        );
      case CheckStatus.available:
        return (
          text: '사용 가능한 이메일입니다.',
          color: successColor,
          isError: false,
        );
      case CheckStatus.duplicated:
      case CheckStatus.error:
        return (text: vm.emailErrorText, color: errorColor, isError: true);
      case CheckStatus.idle:
        return (text: null, color: infoColor, isError: false);
    }
  }

  // ==========================================
  // 6. 공통 입력창 디자인
  // ==========================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    FocusNode? focusNode,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    bool hasError = false,
    Widget? suffixIcon,
    VoidCallback? onEditingComplete,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF29252D),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF99939F),
          ),
          filled: true,
          fillColor: backgroundColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(
              color: hasError ? errorColor : borderColor,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: BorderSide(
              color: hasError ? errorColor : primaryColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 7. 입력 항목 제목
  // ==========================================

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF29252D),
        ),
      ),
    );
  }

  // ==========================================
  // 8. 안내 문구
  // ==========================================

  Widget _buildMessage(
    String? message, {
    required Color color,
  }) {
    if (message == null || message.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: 2,
        top: 6,
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ==========================================
  // 9. 닉네임 입력 영역
  // ==========================================

  Widget _buildNicknameSection() {
    final vm = context.watch<SignUpViewModel>();
    final feedback = _nicknameFeedback(vm);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('닉네임'),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: _nicknameController,
                hint: '닉네임을 입력해주세요',
                textInputAction: TextInputAction.next,
                hasError: feedback.isError,
                onChanged: _onNicknameChanged,
                onEditingComplete: () {
                  _emailFocusNode.requestFocus();
                },
                suffixIcon:
                    vm.nicknameCheckStatus == CheckStatus.available
                        ? const Icon(
                            Icons.check_circle,
                            color: primaryColor,
                            size: 23,
                          )
                        : null,
              ),
            ),

            const SizedBox(width: 10),

            // 입력창(50)과 버튼(44) 높이 차이를 맞추기 위한 여백
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: MovieLogButton(
                label: '중복 확인',
                isLoading: vm.nicknameCheckStatus == CheckStatus.checking,
                onPressed: _isNicknameFormatValid && vm.canCheckNickname
                    ? () => vm.checkNickname(_nicknameController.text)
                    : null,
              ),
            ),
          ],
        ),

        _buildMessage(feedback.text, color: feedback.color),
      ],
    );
  }

  // ==========================================
  // 10. 이메일 입력 영역
  // ==========================================

  Widget _buildEmailSection() {
    final vm = context.watch<SignUpViewModel>();
    final feedback = _emailFeedback(vm);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('이메일'),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                hint: 'movie@umc.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                hasError: feedback.isError,
                onChanged: _onEmailChanged,
                onEditingComplete: () {
                  _passwordFocusNode.requestFocus();
                },
                suffixIcon: vm.emailCheckStatus == CheckStatus.available
                    ? const Icon(
                        Icons.check_circle,
                        color: primaryColor,
                        size: 23,
                      )
                    : null,
              ),
            ),

            const SizedBox(width: 10),

            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: MovieLogButton(
                label: '중복 확인',
                isLoading: vm.emailCheckStatus == CheckStatus.checking,
                onPressed: _isEmailFormatValid && vm.canCheckEmail
                    ? () => vm.checkEmail(_emailController.text)
                    : null,
              ),
            ),
          ],
        ),

        _buildMessage(feedback.text, color: feedback.color),
      ],
    );
  }

  // ==========================================
  // 11. 비밀번호 입력 영역
  // ==========================================

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('비밀번호'),

        _buildTextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          hint: '8자 이상의 비밀번호를 입력해주세요',
          obscureText: true,
          textInputAction: TextInputAction.done,
          hasError: _passwordMessage != null,
          onChanged: _validatePassword,
          onEditingComplete: () {
            FocusScope.of(context).unfocus();
          },
        ),

        _buildMessage(
          _passwordMessage,
          color: errorColor,
        ),
      ],
    );
  }

  // ==========================================
  // 12. 약관 동의 영역
  // ==========================================

  Widget _buildTermsCheckbox() {
    return InkWell(
      onTap: () {
        setState(() {
          _agreedToTerms = !_agreedToTerms;
        });
      },
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _agreedToTerms ? primaryColor : Colors.white,
              border: Border.all(
                color: _agreedToTerms ? primaryColor : borderColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: _agreedToTerms
                ? const Icon(
                    Icons.check,
                    size: 24,
                    color: Colors.white,
                  )
                : null,
          ),

          const SizedBox(width: 9),

          const Text(
            '필수 약관에 동의합니다',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF29252D),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 13. 회원가입 버튼 (전체 너비)
  // ==========================================

  Widget _buildRegisterButton() {
    final vm = context.watch<SignUpViewModel>();

    return MovieLogButton(
      label: '가입하기',
      width: double.infinity,
      onPressed: _canSubmit(vm) ? _submit : null,
    );
  }

  // ==========================================
  // 14. 로그인 이동 영역
  // ==========================================

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '이미 계정이 있나요?',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF39343C),
          ),
        ),

        const SizedBox(width: 15),

        GestureDetector(
          onTap: () {
            // 로그인 화면 연결 예정
          },
          child: const Text(
            '로그인',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 15. 전체 화면
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF29252D),
          ),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      constraints.maxWidth >= 700 ? 560 : double.infinity,
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),

                          // 환영 문구
                          const Column(
                            children: [
                              Text(
                                '환영합니다!',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF29252D),
                                ),
                              ),

                              SizedBox(height: 5),

                              Text(
                                '간단한 정보만 입력하고 시작해보세요.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF39343C),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 34),

                          // 닉네임
                          _buildNicknameSection(),

                          const SizedBox(height: 12),

                          // 이메일
                          _buildEmailSection(),

                          const SizedBox(height: 12),

                          // 비밀번호
                          _buildPasswordSection(),

                          const Spacer(),

                          const SizedBox(height: 32),

                          // 약관 동의
                          _buildTermsCheckbox(),

                          const SizedBox(height: 26),

                          // 가입하기
                          _buildRegisterButton(),

                          const SizedBox(height: 48),

                          // 로그인
                          _buildLoginLink(),

                          const SizedBox(height: 32),
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