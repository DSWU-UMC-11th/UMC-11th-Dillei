import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/network/api_error.dart';
import '../core/storage/token_storage.dart';
import '../data/models/login_models.dart';
import '../data/models/member_info.dart';
import '../data/services/auth_api_service.dart';
import '../data/services/member_api_service.dart';

enum AuthStatus {
  initializing, // 앱 시작: 저장소 확인 중 → Splash
  signedOut, // 로그아웃/만료 → 로그인 화면
  authenticating, // 로그인 요청 중
  signedIn, // 로그인됨
  retryRequired, // 세션 확인 실패(네트워크 등) → 재시도 화면
}

enum MemberLoadStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authApi, this._memberApi, this._storage);

  final AuthApiService _authApi;
  final MemberApiService _memberApi;
  final TokenStorage _storage;

  AuthStatus status = AuthStatus.initializing;
  MemberInfo? member;
  MemberLoadStatus memberStatus = MemberLoadStatus.idle;
  String? message;

  /// 세션 만료로 로그아웃됐을 때만 true. 로그인 화면이 Snackbar를 한 번 띄운 뒤 끕니다.
  bool sessionExpired = false;
  bool storageCleanupInProgress = false;

  int _sessionVersion = 0;
  int get sessionVersion => _sessionVersion;

  bool _disposed = false;
  Future<void>? _tokenWrite;

  bool _isCurrent(int version) => !_disposed && version == _sessionVersion;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // ───────── 앱 시작: 세션 복원 ─────────
  // 토큰이 있다는 사실만으로 signedIn을 확정하지 않고, GET me로 서버 검증을 거칩니다.
  Future<void> restoreSession() async {
    if (storageCleanupInProgress || _disposed) return;
    final version = ++_sessionVersion;
    status = AuthStatus.initializing;
    message = null;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    _notify();

    try {
      final token = await _storage.readAccessToken();
      if (!_isCurrent(version)) return;

      if (token == null || token.isEmpty) {
        status = AuthStatus.signedOut;
      } else {
        final verifiedMember = await _memberApi.fetchMe();
        if (!_isCurrent(version)) return;
        member = verifiedMember;
        memberStatus = MemberLoadStatus.success;
        status = AuthStatus.signedIn;
      }
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;
      if (isAuthExpiredCode(apiErrorCode(error))) {
        await _clearCurrentSession(expired: true);
        return;
      }
      // 네트워크가 잠시 끊겼다고 유효한 토큰을 지우지 않습니다.
      status = AuthStatus.retryRequired;
      message = '로그인 상태를 확인하지 못했어요. 다시 시도해 주세요.';
    } catch (_) {
      if (!_isCurrent(version)) return;
      status = AuthStatus.retryRequired;
      message = '인증 저장소를 읽지 못했어요. 다시 시도해 주세요.';
    }
    if (_isCurrent(version)) _notify();
  }

  // ───────── 로그인 ─────────
  // 신규 로그인: 로그인 API 성공 → 토큰 저장 → signedIn → MainScreen.loadMember()
  Future<void> login(String email, String password) async {
    if (_disposed ||
        storageCleanupInProgress ||
        status == AuthStatus.authenticating) {
      return;
    }
    status = AuthStatus.authenticating;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    sessionExpired = false;
    message = null;
    final version = ++_sessionVersion;
    _notify();

    try {
      final result = await _authApi.login(
        LoginRequest(email: email, password: password),
      );
      if (!_isCurrent(version)) return;

      final writing = _storage.saveAccessToken(result.accessToken);
      _tokenWrite = writing;
      try {
        await writing;
      } finally {
        if (identical(_tokenWrite, writing)) _tokenWrite = null;
      }
      if (!_isCurrent(version)) return;

      status = AuthStatus.signedIn;
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;
      status = AuthStatus.signedOut;
      // AUTH401_1은 로그인 Form 오류입니다. 세션 만료 처리를 하지 않습니다.
      message = apiErrorCode(error) == 'AUTH401_1'
          ? '이메일 또는 비밀번호를 확인해 주세요.'
          : '로그인 요청에 실패했어요. 잠시 후 다시 시도해 주세요.';
    } catch (_) {
      if (!_isCurrent(version)) return;
      status = AuthStatus.signedOut;
      message = '로그인 정보를 안전하게 저장하지 못했어요.';
    }
    _notify();
  }

  // ───────── 내 정보 ─────────
  // MainScreen이 처음 열릴 때 한 번 호출합니다. 재시작 복원은 restoreSession이 이미 채웠습니다.
  Future<void> loadMember({bool force = false}) async {
    if (status != AuthStatus.signedIn) return;
    if (memberStatus == MemberLoadStatus.loading) return;
    if (member != null && !force) return;

    final version = _sessionVersion;
    memberStatus = MemberLoadStatus.loading;
    _notify();

    try {
      final me = await _memberApi.fetchMe();
      if (!_isCurrent(version)) return; // 로그아웃·계정 전환 뒤 늦게 온 응답 무시
      member = me;
      memberStatus = MemberLoadStatus.success;
    } on DioException catch (error) {
      if (!_isCurrent(version)) return;
      if (isAuthExpiredCode(apiErrorCode(error))) {
        await _clearCurrentSession(expired: true);
        return;
      }
      memberStatus = MemberLoadStatus.error; // 로그아웃하지 않고 재시도 가능
      message = '내 정보를 불러오지 못했어요.';
    } catch (_) {
      if (!_isCurrent(version)) return;
      memberStatus = MemberLoadStatus.error;
      message = '내 정보를 불러오지 못했어요.';
    }
    _notify();
  }

  // 프로필 수정 성공 응답으로 메모리의 내 정보를 교체합니다. GET me를 다시 호출하지 않습니다.
  void updateMember(MemberInfo updated) {
    if (_disposed || status != AuthStatus.signedIn) return;
    member = updated;
    _notify();
  }

  // ───────── 로그아웃 / 만료 ─────────
  // 직접 로그아웃: 만료 Snackbar를 켜지 않습니다.
  Future<void> logout() => _clearCurrentSession(expired: false);

  // 다른 ViewModel이 401(AUTH401_2/3/4)을 받았을 때 세션 정리를 요청하는 공개 진입점입니다.
  Future<void> expireSession() => _clearCurrentSession(expired: true);

  void consumeSessionExpired() {
    sessionExpired = false;
  }

  Future<void> _clearCurrentSession({required bool expired}) async {
    if (_disposed || storageCleanupInProgress) return;
    final version = ++_sessionVersion;
    storageCleanupInProgress = true;
    member = null;
    memberStatus = MemberLoadStatus.idle;
    sessionExpired = expired;
    status = AuthStatus.signedOut;
    message = null;
    _notify();

    try {
      // 진행 중이던 토큰 저장을 기다린 뒤 삭제합니다. 정리 중 새 로그인은 막습니다.
      try {
        await _tokenWrite;
      } catch (_) {
        // 저장이 실패했어도 삭제는 시도합니다.
      }
      await _storage.deleteAccessToken();
    } catch (_) {
      if (_isCurrent(version)) {
        message = '저장된 인증 정보를 지우지 못했어요. 앱 재실행 전에 저장소 상태를 확인해 주세요.';
      }
    } finally {
      storageCleanupInProgress = false;
      if (_isCurrent(version)) _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _sessionVersion++;
    super.dispose();
  }
}