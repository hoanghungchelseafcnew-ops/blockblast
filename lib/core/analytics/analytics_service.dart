import '../../features/journey/models/level.dart';

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
