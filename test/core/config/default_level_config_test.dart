import 'package:block_blast/core/config/level_config.dart';
import 'package:block_blast/core/config/level_config_validator.dart';
import 'package:block_blast/core/firebase/default_level_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultLevelConfig', () {
    test('the embedded JSON passes the validator without warnings', () {
      final result = LevelConfigValidator.validate(
        DefaultLevelConfig.json,
        source: ConfigSource.defaults,
      );
      expect(result.errors, isEmpty);
      expect(result.warnings, isEmpty);
      expect(result.isValid, isTrue);
    });

    test('level 1 (Rose Quartz · Rough Stone) targets 500', () {
      final config = DefaultLevelConfig.config;
      expect(
        config.levels['rose_quartz']!.subLevels['rough_stone']!.targetScore,
        500,
      );
    });

    test('contains 6 gems x 6 sub levels with source default', () {
      final config = DefaultLevelConfig.config;
      expect(config.source, ConfigSource.defaults);
      expect(config.levels.keys, GemIds.all);
      expect(
        config.levels.values.fold<int>(0, (n, g) => n + g.subLevels.length),
        36,
      );
    });

    test('Ruby · Bling is the highest target at 350,000 and has no urls', () {
      final config = DefaultLevelConfig.config;
      expect(config.levels['ruby']!.subLevels['bling']!.targetScore, 350000);
      final urls = config.levels.values
          .expand((g) => g.subLevels.values)
          .map((s) => s.backgroundUrl);
      expect(urls.every((u) => u == null), isTrue);
    });

    test('the parsed config is cached across calls', () {
      expect(
        identical(DefaultLevelConfig.config, DefaultLevelConfig.config),
        isTrue,
      );
    });

    test('a corrupted embedded config fails fast with StateError', () {
      expect(() => DefaultLevelConfig.parse('{not json'), throwsStateError);
      expect(
        () => DefaultLevelConfig.parse('{"version": 0, "levels": {}}'),
        throwsStateError,
      );
    });

    test('parse of the embedded constant matches config', () {
      final parsed = DefaultLevelConfig.parse(DefaultLevelConfig.json);
      expect(parsed.source, ConfigSource.defaults);
      expect(parsed.levels.length, DefaultLevelConfig.config.levels.length);
    });
  });
}
