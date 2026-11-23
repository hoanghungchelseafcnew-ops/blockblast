import 'dart:convert';

import '../../../core/log/gj_log.dart';
import 'level.dart';

/// High score của từng level (key `high_scores`, contract E3).
///
/// Bất biến: mỗi lần cập nhật trả về một bản mới. Điểm của một level không
/// bao giờ giảm qua [withScore] (FR2.3b, AC1.7.2).
class HighScores {
  HighScores._(Map<int, int> scores)
    : _scores = Map<int, int>.unmodifiable(scores);

  /// Chưa có điểm nào.
  static final HighScores empty = HighScores._(const <int, int>{});

  final Map<int, int> _scores;

  /// Bản sao chỉ đọc `levelIndex → score`.
  Map<int, int> get asMap => _scores;

  /// Điểm cao nhất của [levelIndex], hoặc 0 nếu chưa có.
  int of(int levelIndex) => _scores[levelIndex] ?? 0;

  /// Bản mới với [score] cho [levelIndex] nếu cao hơn điểm cũ. Trả về chính
  /// bản này khi điểm không cao hơn hoặc [levelIndex] ngoài 1..36.
  HighScores withScore(int levelIndex, int score) {
    if (!_inRange(levelIndex) || score <= of(levelIndex)) return this;
    return HighScores._(<int, int>{..._scores, levelIndex: score});
  }

  String toJsonString() {
    final keys = _scores.keys.toList()..sort();
    return jsonEncode(<String, int>{for (final k in keys) '$k': _scores[k]!});
  }

  /// Parse tolerant (FR8.3, E3 R-07). Trả `null` khi giá trị không phải JSON
  /// object; caller dùng [empty]. Key ngoài 1..36, giá trị không phải số
  /// nguyên không âm và trường lạ bị bỏ qua.
  static HighScores? tryParse(Object? raw) {
    if (raw is! String) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (e) {
      GjLog.warn('Progress', 'high_scores json decode failed', e);
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;
    final scores = <int, int>{};
    decoded.forEach((key, value) {
      final index = int.tryParse(key);
      if (index == null || !_inRange(index)) return;
      if (value is! int || value < 0) return;
      scores[index] = value;
    });
    return HighScores._(scores);
  }

  static bool _inRange(int value) => value >= 1 && value <= Level.totalLevels;
}
