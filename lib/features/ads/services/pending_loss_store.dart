import 'dart:async';

import '../../../core/log/gj_log.dart';
import '../../journey/services/progress_store.dart';

/// Một lần thua ở Journey chưa được ghi nhận (u2-reward-ads, BR6.7).
class PendingLoss {
  const PendingLoss({required this.levelIndex, required this.score});

  final int levelIndex;
  final int score;
}

/// Dấu lần thua chưa ghi nhận, lưu bền qua [ProgressStore].
///
/// Khi nút WATCH AD TO TRY AGAIN có thể hiện, ván thua chưa hạ tiến trình
/// ngay. Dấu này đảm bảo ứng dụng bị tắt ở lớp phủ Game Over vẫn ghi nhận
/// thua ở lần mở sau (BR6.7). Chỉ lưu số level và điểm, không có dữ liệu cá
/// nhân (NFR2.14). Lỗi đọc hoặc ghi được log và không bao giờ ném ra ngoài.
class PendingLossStore {
  PendingLossStore(this._store);

  static const String key = 'pending_loss_level';

  static const String _log = 'PendingLoss';

  final ProgressStore _store;
  Future<bool>? _opening;

  /// Mở kho lưu một lần. Trả false nếu không mở được.
  Future<bool> _open() => _opening ??= _init();

  Future<bool> _init() async {
    try {
      await _store.init();
      return true;
    } catch (e) {
      GjLog.warn(_log, 'opening store failed', e);
      return false;
    }
  }

  /// Ghi dấu thua chưa ghi nhận cho [levelIndex] với [score]. Trả false nếu
  /// không ghi được.
  Future<bool> mark(int levelIndex, int score) async {
    if (!await _open()) return false;
    try {
      await _store.writeString(key, '$levelIndex:$score');
      return true;
    } catch (e) {
      GjLog.warn(_log, 'saving pending loss failed', e);
      return false;
    }
  }

  /// Xóa dấu sau khi lần thua đã được ghi nhận hoặc đã nhận thưởng.
  Future<void> clear() async {
    if (!await _open()) return;
    try {
      await _store.remove(key);
    } catch (e) {
      GjLog.warn(_log, 'clearing pending loss failed', e);
    }
  }

  /// Dấu đã lưu, hoặc null nếu không có hay giá trị hỏng.
  Future<PendingLoss?> read() async {
    if (!await _open()) return null;
    try {
      final raw = _store.read(key);
      if (raw == null) return null;
      final parsed = _parse(raw);
      if (parsed == null) {
        GjLog.warn(_log, 'ignoring invalid pending loss value');
      }
      return parsed;
    } catch (e) {
      GjLog.warn(_log, 'reading pending loss failed', e);
      return null;
    }
  }

  static PendingLoss? _parse(Object raw) {
    if (raw is! String) return null;
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    final level = int.tryParse(parts[0]);
    final score = int.tryParse(parts[1]);
    if (level == null || score == null || level < 1 || score < 0) return null;
    return PendingLoss(levelIndex: level, score: score);
  }
}
