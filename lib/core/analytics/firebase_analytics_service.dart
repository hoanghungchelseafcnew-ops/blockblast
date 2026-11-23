import 'package:firebase_analytics/firebase_analytics.dart';

import '../../features/journey/models/level.dart';
import '../log/gj_log.dart';
import 'analytics_service.dart';

/// Ranh giới duy nhất với SDK Firebase Analytics. Test thay bằng bản giả.
abstract class AnalyticsClient {
  Future<void> logEvent(String name, Map<String, Object> parameters);
  Future<void> setUserProperty(String name, String value);
}

/// Bọc `FirebaseAnalytics.instance`. Chỉ dựng khi Firebase đã khởi tạo xong.
/// SDK tự xếp hàng event khi offline và gửi lại khi có mạng (FR4.3).
class FirebaseAnalyticsClient implements AnalyticsClient {
  FirebaseAnalyticsClient([FirebaseAnalytics? analytics])
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) =>
      _analytics.logEvent(name: name, parameters: parameters);

  @override
  Future<void> setUserProperty(String name, String value) =>
      _analytics.setUserProperty(name: name, value: value);
}

/// Triển khai contract C4 theo schema E2. Không bao giờ throw: lỗi SDK được
/// log với tên event và `err.runtimeType`.
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService(this._client);

  final AnalyticsClient _client;

  @override
  Future<void> logLevelStart(Level level) =>
      _levelEvent(AnalyticsNames.levelStart, level);

  @override
  Future<void> logLevelComplete(Level level, int score, int target) =>
      _levelEvent(AnalyticsNames.levelComplete, level, score, target);

  @override
  Future<void> logLevelFail(Level level, int score, int target) =>
      _levelEvent(AnalyticsNames.levelFail, level, score, target);

  @override
  Future<void> logGameSession(int durationSec) {
    return _event(AnalyticsNames.gameSession, <String, Object>{
      AnalyticsNames.durationSec: durationSec < 0 ? 0 : durationSec,
    });
  }

  @override
  Future<void> setProgressProperties(
    String currentMajorLevel,
    int highestLevelReached,
  ) async {
    await _property(AnalyticsNames.currentMajorLevel, currentMajorLevel);
    // E2: user property là chuỗi; khi phân tích phải ép sang số.
    await _property(AnalyticsNames.highestLevelReached, '$highestLevelReached');
  }

  @override
  Future<void> setConfigSource(String source) =>
      _property(AnalyticsNames.configSource, source);

  Future<void> _levelEvent(
    String name,
    Level level, [
    int? score,
    int? target,
  ]) {
    final params = AnalyticsNames.levelParams(level);
    if (params == null) {
      GjLog.warn(
        'Analytics',
        '$name skipped: level_index out of range (${level.levelIndex})',
      );
      return Future<void>.value();
    }
    if (score != null) params[AnalyticsNames.score] = score;
    if (target != null) params[AnalyticsNames.target] = target;
    return _event(name, params);
  }

  Future<void> _event(String name, Map<String, Object> params) async {
    try {
      await _client.logEvent(name, params);
    } catch (e) {
      GjLog.warn('Analytics', 'event $name failed', e);
    }
  }

  Future<void> _property(String name, String value) async {
    try {
      await _client.setUserProperty(name, value);
    } catch (e) {
      GjLog.warn('Analytics', 'user property $name failed', e);
    }
  }
}
