import '../../features/journey/services/progress_repository.dart';
import '../log/gj_log.dart';
import '../utils/clock.dart';
import 'analytics_service.dart';

/// Đo một phiên chơi, từ lúc app mở hoặc quay lại foreground tới lúc vào
/// nền. Khi vào nền, gửi `game_session{duration_sec}` (FR4.1, AC6.4.1) và
/// cộng thời gian vào `total_play_time` (FR8.1, AC1.6.2).
class SessionTracker {
  SessionTracker({
    required AnalyticsService analytics,
    required ProgressRepository progress,
    Clock clock = const SystemClock(),
  }) : _analytics = analytics,
       _progress = progress,
       _clock = clock;

  final AnalyticsService _analytics;
  final ProgressRepository _progress;
  final Clock _clock;

  DateTime? _startedAt;

  /// Đang đếm một phiên hay không.
  bool get isRunning => _startedAt != null;

  /// Bắt đầu phiên (app mở hoặc `resumed`). Gọi lại khi đang đếm thì giữ
  /// mốc cũ.
  void start() {
    _startedAt ??= _clock.now();
  }

  /// Kết thúc phiên (`paused`). Gọi khi không có phiên nào thì không làm gì.
  /// Phiên 0 giây không gửi gì. Không bao giờ throw.
  Future<void> pause() async {
    final started = _startedAt;
    if (started == null) return;
    _startedAt = null;
    final seconds = _clock.now().difference(started).inSeconds;
    if (seconds <= 0) return;
    try {
      await _analytics.logGameSession(seconds);
    } catch (e) {
      GjLog.warn('Session', 'game_session failed', e);
    }
    try {
      await _progress.addPlayTime(seconds);
    } catch (e) {
      GjLog.warn('Session', 'saving play time failed', e);
    }
  }
}
