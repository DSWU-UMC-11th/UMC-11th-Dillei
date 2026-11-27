class SessionGuard {
  int _generation = 0;
  String? _accountId;

  int get generation => _generation;
  String? get accountId => _accountId;

  // 인증이 검증된 새 세션을 시작할 때만 호출합니다.
  int startSession(String accountId) {
    _accountId = accountId;
    return ++_generation;
  }

  void invalidate() {
    _accountId = null;
    _generation++;
  }

  bool isCurrent(int generation, String accountId) =>
      _generation == generation && _accountId == accountId;
}