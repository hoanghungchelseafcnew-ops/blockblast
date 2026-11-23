import 'package:block_blast/core/analytics/analytics_service.dart';
import 'package:block_blast/core/firebase/default_level_config.dart';
import 'package:block_blast/features/journey/models/level.dart';
import 'package:block_blast/features/journey/services/level_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

Level _withIndex(Level base, int index) => Level(
  levelIndex: index,
  gemId: base.gemId,
  gemName: base.gemName,
  gemOrder: base.gemOrder,
  subId: base.subId,
  subName: base.subName,
  subOrder: base.subOrder,
  targetScore: base.targetScore,
  assetPath: base.assetPath,
);

void main() {
  final catalog = LevelCatalog.from(DefaultLevelConfig.config);

  test('event names are exactly those of contract E2', () {
    expect(
      [
        AnalyticsNames.levelStart,
        AnalyticsNames.levelComplete,
        AnalyticsNames.levelFail,
        AnalyticsNames.gameSession,
      ],
      ['level_start', 'level_complete', 'level_fail', 'game_session'],
    );
  });

  test('parameter and user property names are exactly those of E2', () {
    expect(
      [
        AnalyticsNames.major,
        AnalyticsNames.sub,
        AnalyticsNames.levelIndex,
        AnalyticsNames.score,
        AnalyticsNames.target,
        AnalyticsNames.durationSec,
      ],
      ['major', 'sub', 'level_index', 'score', 'target', 'duration_sec'],
    );
    expect(
      [
        AnalyticsNames.currentMajorLevel,
        AnalyticsNames.highestLevelReached,
        AnalyticsNames.configSource,
      ],
      ['current_major_level', 'highest_level_reached', 'config_source'],
    );
  });

  test('level params of level 1 and level 36', () {
    expect(AnalyticsNames.levelParams(catalog.byIndex(1)), {
      'major': 'rose_quartz',
      'sub': 'rough_stone',
      'level_index': 1,
    });
    expect(AnalyticsNames.levelParams(catalog.byIndex(36)), {
      'major': 'ruby',
      'sub': 'bling',
      'level_index': 36,
    });
  });

  test('a level index outside 1..36 is rejected (AC6.3.1)', () {
    final base = catalog.byIndex(1);
    expect(AnalyticsNames.levelParams(_withIndex(base, 0)), isNull);
    expect(AnalyticsNames.levelParams(_withIndex(base, 37)), isNull);
  });
}
