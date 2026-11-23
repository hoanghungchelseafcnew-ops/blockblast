/// Trạng thái ván endless của một round (ER3, ER6, ER14).
///
/// Mọi `switch` trên enum này phải liệt kê đủ case, không dùng `default`.
enum EndlessStatus {
  playing,

  /// Đang lưu điểm sau khi thua hoặc QUIT; input và back bị bỏ qua.
  saving,
  lost,
  quit,
}

/// Điểm endless đã lưu (keys `endless_saved_score`, `endless_high_score`,
/// contract C5/E3).
class EndlessState {
  const EndlessState({this.savedScore = 0, this.highScore = 0});

  static const EndlessState initial = EndlessState();

  /// Điểm để tiếp tục ở lần PLAY sau (FR9.2).
  final int savedScore;

  /// Điểm cao nhất của endless (FR9.5).
  final int highScore;

  /// Bản mới với điểm đã lưu là [score] và high score không giảm (ER7).
  EndlessState saving(int score) {
    final s = score < 0 ? 0 : score;
    return EndlessState(
      savedScore: s,
      highScore: s > highScore ? s : highScore,
    );
  }

  /// Sau khi thua: điểm đã lưu về 0, high score lấy [score] nếu cao hơn (ER6).
  EndlessState afterLoss(int score) {
    final s = score < 0 ? 0 : score;
    return EndlessState(highScore: s > highScore ? s : highScore);
  }

  @override
  bool operator ==(Object other) =>
      other is EndlessState &&
      other.savedScore == savedScore &&
      other.highScore == highScore;

  @override
  int get hashCode => Object.hash(savedScore, highScore);

  @override
  String toString() => 'EndlessState(saved: $savedScore, high: $highScore)';
}
