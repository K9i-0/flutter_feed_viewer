extension DateTimeX on DateTime {
  /// 経過時間
  String get elapsedTime {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inDays > 0) {
      return '${diff.inDays}日前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}時間前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }
}
