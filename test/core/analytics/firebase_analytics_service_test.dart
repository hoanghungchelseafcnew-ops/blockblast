import 'package:block_blast/core/analytics/firebase_analytics_service.dart';
import 'package:block_blast/core/firebase/default_level_config.dart';
import 'package:block_blast/features/journey/models/level.dart';
import 'package:block_blast/features/journey/services/level_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_analytics.dart';
import '../../fakes/log_capture.dart';

void main() {
  late LogCapture log;
  late FakeAnalyticsClient client;
  late FirebaseAnalyticsService analytics;
  final catalog = LevelCatalog.from(DefaultLevelConfig.config);

  setUp(() {
    log = LogCapture()..start();
    client = FakeAnalyticsClient();
    analytics = FirebaseAnalyticsService(client);
  });

  test('level_start carries major, sub and level_index (AC6.3.1)', () async {
    await analytics.logLevelStart(catalog.byIndex(9));
    expect(client.events.single.$1, 'level_start');
    expect(client.events.single.$2, {
      'major': 'amethyst',
      'sub': 'shaping',
      'level_index': 9,
    });
  });

  test('level_complete and level_fail add score and target', () async {
    await analytics.logLevelComplete(catalog.byIndex(1), 520, 500);
    await analytics.logLevelFail(catalog.byIndex(36), 1200, 350000);
    expect(client.names, ['level_complete', 'level_fail']);
    expect(client.events[0].$2, {
      'major': 'rose_quartz',
      'sub': 'rough_stone',
      'level_index': 1,
      'score': 520,
      'target': 500,
    });
    expect(client.events[1].$2['level_index'], 36);
    expect(client.events[1].$2['score'], 1200);
    expect(client.events[1].$2['target'], 350000);
  });

  test('a level outside 1..36 sends nothing and logs', () async {
    final base = catalog.byIndex(1);
    final bad = Level(
      levelIndex: 40,
      gemId: base.gemId,
      gemName: base.gemName,
      gemOrder: base.gemOrder,
      subId: base.subId,
      subName: base.subName,
      subOrder: base.subOrder,
      targetScore: base.targetScore,
      assetPath: base.assetPath,
    );
    await analytics.logLevelStart(bad);
    expect(client.events, isEmpty);
    expect(log.where('level_index out of range'), hasLength(1));
  });

  test('game_session carries duration_sec, never negative', () async {
    await analytics.logGameSession(90);
    await analytics.logGameSession(-5);
    expect(client.names, ['game_session', 'game_session']);
    expect(client.events[0].$2, {'duration_sec': 90});
    expect(client.events[1].$2, {'duration_sec': 0});
  });

  test('progress user properties: highest_level_reached is a string '
      '(AC6.4.2, E2)', () async {
    await analytics.setProgressProperties('emerald', 22);
    expect(client.properties, {
      'current_major_level': 'emerald',
      'highest_level_reached': '22',
    });
  });

  test('config_source accepts remote, cached and default', () async {
    for (final source in ['remote', 'cached', 'default']) {
      await analytics.setConfigSource(source);
      expect(client.properties['config_source'], source);
    }
  });

  test('SDK errors are logged and never thrown', () async {
    client.fail = true;
    await analytics.logLevelStart(catalog.byIndex(1));
    await analytics.logGameSession(10);
    await analytics.setConfigSource('remote');
    expect(log.where('event level_start failed'), hasLength(1));
    expect(log.where('event game_session failed'), hasLength(1));
    expect(log.where('user property config_source failed'), hasLength(1));
  });
}
