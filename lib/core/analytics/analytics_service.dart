import '../../features/journey/models/level.dart';

/// Tên event, tham số và user property, đúng nguyên văn contract E2. Chỉ được
/// thêm; đổi nghĩa hoặc đổi tên thì tạo event mới hậu tố `_v2`.
abstract final class AnalyticsNames {
  static const String levelStart = 'level_start';
  static const String levelComplete = 'level_complete';
  static const String levelFail = 'level_fail';
  static const String gameSession = 'game_session';

  static const String major = 'major';
  static const String sub = 'sub';
  static const String levelIndex = 'level_index';
  static const String score = 'score';
  static const String target = 'target';
  static const String durationSec = 'duration_sec';

  static const String currentMajorLevel = 'current_major_level';
  static const String highestLevelReached = 'highest_level_reached';
  static const String configSource = 'config_source';

  /// Tham số chung của event level: `{major, sub, level_index}`. Trả null khi
  /// `level_index` ngoài 1..36 (E2), để caller bỏ event thay vì gửi dữ liệu sai.
  static Map<String, Object>? levelParams(Level level) {
    final index = level.levelIndex;
    if (index < 1 || index > Level.totalLevels) return null;
    return <String, Object>{
      major: level.gemId,
      sub: level.subId,
      levelIndex: index,
    };
  }
}

/// Contract C4: sự kiện analytics của hành trình.
///
/// U1 chỉ định nghĩa interface và [NoopAnalyticsService]; U5 triển khai bản
/// Firebase. Mọi hàm hoàn tất bình thường và không bao giờ throw: lỗi SDK được
/// bản triển khai tự log.
abstract class AnalyticsService {
  Future<void> logLevelStart(Level level);

  Future<void> logLevelComplete(Level level, int score, int target);

  Future<void> logLevelFail(Level level, int score, int target);

  Future<void> logGameSession(int durationSec);

  Future<void> setProgressProperties(
    String currentMajorLevel,
    int highestLevelReached,
  );

  /// `remote`, `cached` hoặc `default`; gọi một lần sau bootstrap.
  Future<void> setConfigSource(String source);
}

/// Bản mặc định ở U1: không gửi gì đi.
class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> logLevelStart(Level level) async {}

  @override
  Future<void> logLevelComplete(Level level, int score, int target) async {}

  @override
  Future<void> logLevelFail(Level level, int score, int target) async {}

  @override
  Future<void> logGameSession(int durationSec) async {}

  @override
  Future<void> setProgressProperties(
    String currentMajorLevel,
    int highestLevelReached,
  ) async {}

  @override
  Future<void> setConfigSource(String source) async {}
}
