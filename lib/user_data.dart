class UserData {
  static String? username = "";
  static String? password = "";

  // Lưu lượt cho từng user
  static final Map<String, int> _userClicks = {};
  static final Map<String, DateTime?> _lastExhaustedTime = {};

  /// Lấy số lượt còn lại
  static int getRemainingClicks(String user) {
    return _userClicks[user] ?? 3;
  }

  /// Trừ 1 lượt
  static void useClick(String user) {
    final clicks = _userClicks[user] ?? 3;
    if (clicks > 0) {
      _userClicks[user] = clicks - 1;
      if (_userClicks[user] == 0) {
        _lastExhaustedTime[user] = DateTime.now();
      }
    }
  }

  /// Kiểm tra và reset nếu đủ 24h
  static String checkAndResetClicks(String user) {
    if ((_userClicks[user] ?? 3) == 0 && _lastExhaustedTime[user] != null) {
      final now = DateTime.now();
      final diff = now.difference(_lastExhaustedTime[user]!);

      if (diff.inHours >= 24) {
        _userClicks[user] = 3;
        _lastExhaustedTime[user] = null;
        return "✅ Lượt đã được làm mới! Bạn có 3 lượt mới.";
      } else {
        final remaining = Duration(hours: 24) - diff;

        final hours = remaining.inHours;
        final minutes = remaining.inMinutes % 60;
        final seconds = remaining.inSeconds % 60;

        return "⏳ Bạn đã hết lượt. Vui lòng quay lại sau "
            "${hours.toString().padLeft(2, '0')}:"
            "${minutes.toString().padLeft(2, '0')}:"
            "${seconds.toString().padLeft(2, '0')}";
      }
    }
    return "";
  }
}
