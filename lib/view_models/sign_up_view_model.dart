
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../data/services/sign_up_service.dart';
import '../data/models/create_member_request.dart';

enum CheckStatus {
  idle,
  checking,
  available,
  duplicated,
  error,
}

enum SubmitStatus {
  idle,
  submitting,
  success,
  error,
}

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel(this._service);

  final SignUpService _service;

  bool _disposed = false;

  // 닉네임 중복 확인
  CheckStatus nicknameCheckStatus = CheckStatus.idle;
  String? nicknameErrorText;
  String? _duplicatedNickname;
  String _currentNickname = '';
  int _nicknameRequestVersion = 0;

  bool get canCheckNickname =>
      nicknameCheckStatus != CheckStatus.checking &&
      nicknameCheckStatus != CheckStatus.duplicated;

  void onNicknameChanged(String value) {
    final trimmed = value.trim();
    _currentNickname = trimmed;
    _nicknameRequestVersion++;

    if (_duplicatedNickname != null &&
        trimmed == _duplicatedNickname) {
      nicknameCheckStatus = CheckStatus.duplicated;
      nicknameErrorText = '이미 사용 중인 닉네임입니다.';
    } else {
      nicknameCheckStatus = CheckStatus.idle;
      nicknameErrorText = null;
    }

    _clearSubmitErrors();
    _notify();
  }

  Future<void> checkNickname(String value) async {
    final requested = value.trim();

    if (requested.isEmpty ||
        requested != _currentNickname ||
        !canCheckNickname) {
      return;
    }

    final version = ++_nicknameRequestVersion;
    nicknameCheckStatus = CheckStatus.checking;
    nicknameErrorText = null;
    _notify();

    try {
      final available = await _service.checkNickname(requested);

      if (_disposed ||
          version != _nicknameRequestVersion ||
          _currentNickname != requested) {
        return;
      }

      nicknameCheckStatus =
          available ? CheckStatus.available : CheckStatus.duplicated;

      nicknameErrorText =
          available ? null : '이미 사용 중인 닉네임입니다.';

      if (!available) {
        _duplicatedNickname = requested;
      }
    } on DioException {
      if (_disposed ||
          version != _nicknameRequestVersion ||
          _currentNickname != requested) {
        return;
      }

      nicknameCheckStatus = CheckStatus.error;
      nicknameErrorText = '중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }

    if (!_disposed && version == _nicknameRequestVersion) {
      notifyListeners();
    }
  }

  // 이메일 중복 확인
  CheckStatus emailCheckStatus = CheckStatus.idle;
  String? emailErrorText;
  String? _duplicatedEmail;
  String _currentEmail = '';
  int _emailRequestVersion = 0;

  bool get canCheckEmail =>
      emailCheckStatus != CheckStatus.checking &&
      emailCheckStatus != CheckStatus.duplicated;

  void onEmailChanged(String value) {
    final trimmed = value.trim();
    _currentEmail = trimmed;
    _emailRequestVersion++;

    if (_duplicatedEmail != null &&
        trimmed == _duplicatedEmail) {
      emailCheckStatus = CheckStatus.duplicated;
      emailErrorText = '이미 사용 중인 이메일입니다.';
    } else {
      emailCheckStatus = CheckStatus.idle;
      emailErrorText = null;
    }

    _clearSubmitErrors();
    _notify();
  }

  Future<void> checkEmail(String value) async {
    final requested = value.trim();

    if (requested.isEmpty ||
        requested != _currentEmail ||
        !canCheckEmail) {
      return;
    }

    final version = ++_emailRequestVersion;
    emailCheckStatus = CheckStatus.checking;
    emailErrorText = null;
    _notify();

    try {
      final available = await _service.checkEmail(requested);

      if (_disposed ||
          version != _emailRequestVersion ||
          _currentEmail != requested) {
        return;
      }

      emailCheckStatus =
          available ? CheckStatus.available : CheckStatus.duplicated;

      emailErrorText =
          available ? null : '이미 사용 중인 이메일입니다.';

      if (!available) {
        _duplicatedEmail = requested;
      }
    } on DioException {
      if (_disposed ||
          version != _emailRequestVersion ||
          _currentEmail != requested) {
        return;
      }

      emailCheckStatus = CheckStatus.error;
      emailErrorText = '이메일 중복 확인에 실패했습니다. 다시 시도해 주세요.';
    }

    if (!_disposed && version == _emailRequestVersion) {
      notifyListeners();
    }
  }

  // 회원가입 제출
  SubmitStatus submitStatus = SubmitStatus.idle;
  int? createdMemberId;
  String? passwordErrorText;
  String? snackbarMessage;

  // 닉네임과 이메일 중복 확인이 모두 통과해야 가입 가능
  bool get canSubmit =>
      nicknameCheckStatus == CheckStatus.available &&
      emailCheckStatus == CheckStatus.available &&
      submitStatus != SubmitStatus.submitting;

  void onPasswordChanged() {
    passwordErrorText = null;
    snackbarMessage = null;
    _notify();
  }

  void _clearSubmitErrors() {
    passwordErrorText = null;
    snackbarMessage = null;
  }

  Future<void> submit(CreateMemberRequest request) async {
    if (!canSubmit) return;

    submitStatus = SubmitStatus.submitting;
    createdMemberId = null;
    _clearSubmitErrors();
    _notify();

    try {
      final response = await _service.signUp(request);

      if (_disposed) return;

      final memberId = response.result?.memberId;

      if (memberId == null) {
        throw StateError('회원가입 결과에 memberId가 없습니다.');
      }

      createdMemberId = memberId;
      submitStatus = SubmitStatus.success;
    } on DioException catch (error) {
      if (_disposed) return;

      submitStatus = SubmitStatus.error;

      final message = writeSignUpErrorMessage(error);

      if (error.response?.statusCode == 400 &&
          message.contains('비밀번호')) {
        passwordErrorText = message;
      } else {
        snackbarMessage = message;
      }
    } on StateError {
      if (_disposed) return;

      submitStatus = SubmitStatus.error;
      snackbarMessage =
          '가입 결과를 확인하지 못했습니다. 서버 상태를 확인해 주세요.';
    }

    _notify();
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _nicknameRequestVersion++;
    _emailRequestVersion++;
    super.dispose();
  }
}
