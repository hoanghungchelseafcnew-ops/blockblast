import 'package:block_blast/core/analytics/analytics_service.dart';
import 'package:block_blast/core/firebase/default_level_config.dart';
import 'package:block_blast/features/journey/services/level_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoopAnalyticsService (contract C4)', () {
    const AnalyticsService analytics = NoopAnalyticsService();
    final level = LevelCatalog.from(DefaultLevelConfig.config).byIndex(1);

    test('level events complete normally', () async {
      await expectLater(analytics.logLevelStart(level), completes);
      await expectLater(analytics.logLevelComplete(level, 600, 500), completes);
      await expectLater(analytics.logLevelFail(level, 100, 500), completes);
    });

    test('session and user properties complete normally', () async {
      await expectLater(analytics.logGameSession(42), completes);
      await expectLater(
        analytics.setProgressProperties('rose_quartz', 3),
        completes,
      );
    });

    test('every config source value is accepted without throwing', () async {
      for (final source in ['remote', 'cached', 'default']) {
        await expectLater(analytics.setConfigSource(source), completes);
      }
    });

    test('edge values do not throw', () async {
      await expectLater(analytics.logGameSession(0), completes);
      await expectLater(analytics.logLevelFail(level, 0, 1), completes);
      await expectLater(analytics.setProgressProperties('', 1), completes);
    });
  });
}
