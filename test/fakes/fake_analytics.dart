import 'package:block_blast/core/analytics/analytics_service.dart';
import 'package:block_blast/core/analytics/firebase_analytics_service.dart';
import 'package:block_blast/features/journey/models/level.dart';

/// Client SDK giả: ghi lại mọi event và user property.
class FakeAnalyticsClient implements AnalyticsClient {
  final List<(String, Map<String, Object>)> events = [];
  final Map<String, String> properties = {};
  bool fail = false;

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async {
    if (fail) throw StateError('sdk failed');
    events.add((name, Map<String, Object>.of(parameters)));
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    if (fail) throw StateError('sdk failed');
    properties[name] = value;
  }

  List<String> get names => [for (final e in events) e.$1];
}

/// Service analytics giả ở mức contract C4, cho controller và session.
class FakeAnalytics implements AnalyticsService {
  final List<String> calls = [];
  final List<int> sessions = [];
  String? configSource;
  String? currentMajorLevel;
  int? highestLevelReached;

  @override
  Future<void> logLevelStart(Level level) async =>
      calls.add('start:${level.levelIndex}');

  @override
  Future<void> logLevelComplete(Level level, int score, int target) async =>
      calls.add('complete:${level.levelIndex}:$score/$target');

  @override
  Future<void> logLevelFail(Level level, int score, int target) async =>
      calls.add('fail:${level.levelIndex}:$score/$target');

  @override
  Future<void> logGameSession(int durationSec) async =>
      sessions.add(durationSec);

  @override
  Future<void> setProgressProperties(
    String currentMajorLevel,
    int highestLevelReached,
  ) async {
    this.currentMajorLevel = currentMajorLevel;
    this.highestLevelReached = highestLevelReached;
  }

  @override
  Future<void> setConfigSource(String source) async => configSource = source;
}
