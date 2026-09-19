import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _id = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  final _email = TextEditingController();
  final _nickname = TextEditingController();
  String _domain = '직접입력';
  bool _idChecked = false;

  @override
  void dispose() {
    _id.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    _email.dispose();
    _nickname.dispose();
    super.dispose();
  }

  void _submit() {
    final valid = _id.text.trim().isNotEmpty &&
        _password.text.isNotEmpty &&
        _password.text == _passwordConfirm.text &&
        _email.text.trim().isNotEmpty &&
        _nickname.text.trim().isNotEmpty;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(valid ? '가입이 완료되었습니다!' : '모든 정보를 올바르게 입력해주세요.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA8B4D4),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 82,
              color: const Color(0xFF7055A7),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const MovieLogo(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Expanded(
                    child: Text(
                      '회원가입',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _submit,
                    icon: const Icon(
                      Icons.settings,
                      color: Color(0xFFA4A3A4),
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 54, 24, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('아이디'),
                    _idField(),
                    const SizedBox(height: 35),
                    _label('비밀번호'),
                    PixelTextField(
                      controller: _password,
                      hintText: '비밀번호',
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),
                    PixelTextField(
                      controller: _passwordConfirm,
                      hintText: '비밀번호 확인',
                      obscureText: true,
                    ),
                    const SizedBox(height: 35),
                    _label('이메일'),
                    _emailField(),
                    const SizedBox(height: 35),
                    _label('닉네임'),
                    PixelTextField(
                      controller: _nickname,
                      hintText: 'ex) 팔콘먹는 자라',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 82,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D247F),
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(),
                  elevation: 0,
                ),
                child: const Text(
                  '가입하기',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String label) => Padding(
        padding: const EdgeInsets.only(left: 2, bottom: 17),
        child: Text(
          label,
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
        ),
      );

  Widget _idField() => ClipPath(
        clipper: const PixelClipper(),
        child: Row(
          children: [
            Expanded(
              child: PixelTextField(controller: _id, hintText: '아이디'),
            ),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () =>
                    setState(() => _idChecked = _id.text.trim().isNotEmpty),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4DFAB),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(),
                ),
                child: Text(
                  _idChecked ? '확인완료' : '중복확인',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _emailField() => ClipPath(
        clipper: const PixelClipper(),
        child: Row(
          children: [
            Expanded(
              child: PixelTextField(controller: _email, hintText: '이메일'),
            ),
            Container(
              height: 56,
              color: const Color(0xFFD4DFAB),
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _domain,
                  isDense: true,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF7055A7),
                    size: 30,
                  ),
                  items: const ['직접입력', 'naver.com', 'gmail.com']
                      .map(
                        (domain) => DropdownMenuItem(
                          value: domain,
                          child: Text(
                            domain,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _domain = value!),
                ),
              ),
            ),
          ],
        ),
      );
}

class MovieLogo extends StatelessWidget {
  const MovieLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.movie_outlined, color: Colors.white, size: 36);
  }
}

class PixelTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const PixelTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 56,
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class PixelClipper extends CustomClipper<Path> {
  const PixelClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}