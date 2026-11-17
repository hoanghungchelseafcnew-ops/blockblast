import 'dart:convert';
import 'dart:io';

import 'package:block_blast/core/config/level_config.dart';
import 'package:block_blast/core/config/level_config_validator.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _fixture() =>
    jsonDecode(File('test/fixtures/level_config_valid.json').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> _sub(Map<String, dynamic> cfg, String gem, String sub) =>
    ((cfg['levels'] as Map<String, dynamic>)[gem]
            as Map<String, dynamic>)['sub_levels'][sub]
        as Map<String, dynamic>;

ValidationResult _validate(Map<String, dynamic> cfg) =>
    LevelConfigValidator.validate(jsonEncode(cfg), source: ConfigSource.remote);

void main() {
  group('LevelConfigValidator', () {
    test('accepts the valid 6x6 fixture and ignores unknown fields', () {
      final result = _validate(_fixture());
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
      final config = result.config!;
      expect(config.version, 1);
      expect(config.source, ConfigSource.remote);
      expect(config.levels.length, 6);
      expect(config.levels.values.every((g) => g.subLevels.length == 6), isTrue);
      expect(config.levels['rose_quartz']!.subLevels['rough_stone']!.targetScore,
          500);
    });

    test('keeps valid background urls and trims them', () {
      final config = _validate(_fixture()).config!;
      expect(
        config.levels['rose_quartz']!.subLevels['rough_stone']!.backgroundUrl,
        startsWith('https://firebasestorage.googleapis.com/'),
      );
      expect(
        config.levels['rose_quartz']!.subLevels['slabbing']!.backgroundUrl,
        isNull,
      );
    });

    test('rejects the whole config when a gem is missing', () {
      final cfg = _fixture();
      (cfg['levels'] as Map<String, dynamic>).remove('ruby');
      final result = _validate(cfg);
      expect(result.config, isNull);
      expect(result.firstError, 'invalid_levels');
    });

    test('rejects an unknown gem key in place of a known one', () {
      final cfg = _fixture();
      final levels = cfg['levels'] as Map<String, dynamic>;
      levels['jade'] = levels.remove('ruby');
      expect(_validate(cfg).firstError, 'missing_gem:ruby');
    });

    test('rejects a gem with a missing sub level', () {
      final cfg = _fixture();
      final gem = (cfg['levels'] as Map<String, dynamic>)['emerald']
          as Map<String, dynamic>;
      (gem['sub_levels'] as Map<String, dynamic>).remove('bling');
      expect(_validate(cfg).firstError, 'invalid_sub_levels:emerald');
    });

    test('rejects duplicate sub order and duplicate gem order', () {
      final dupSub = _fixture();
      _sub(dupSub, 'amethyst', 'slabbing')['order'] = 1;
      expect(_validate(dupSub).firstError, 'invalid_sub_order:amethyst.slabbing');

      final dupGem = _fixture();
      ((dupGem['levels'] as Map<String, dynamic>)['sapphire']
          as Map<String, dynamic>)['order'] = 1;
      expect(_validate(dupGem).firstError, 'invalid_gem_order:sapphire');
    });

    test('rejects targetScore outside 1..10,000,000 or not an integer', () {
      for (final bad in <Object>[0, -5, 10000001, 12.5, '500', true]) {
        final cfg = _fixture();
        _sub(cfg, 'amethyst', 'shaping')['target_score'] = bad;
        final result = _validate(cfg);
        expect(result.config, isNull, reason: '$bad');
        expect(result.firstError, 'invalid_target_score:amethyst.shaping');
      }
    });

    test('accepts targetScore at both bounds', () {
      final cfg = _fixture();
      _sub(cfg, 'ruby', 'bling')['target_score'] = 10000000;
      _sub(cfg, 'rose_quartz', 'rough_stone')['target_score'] = 1;
      expect(_validate(cfg).isValid, isTrue);
    });

    test('rejects a missing, zero or non-integer version', () {
      for (final bad in <Object?>[null, 0, -1, '1', 1.5]) {
        final cfg = _fixture();
        if (bad == null) {
          cfg.remove('version');
        } else {
          cfg['version'] = bad;
        }
        expect(_validate(cfg).firstError, 'invalid_version', reason: '$bad');
      }
    });

    test('accepts any version >= 1 (E1)', () {
      final cfg = _fixture()..['version'] = 7;
      expect(_validate(cfg).config!.version, 7);
    });

    test('rejects malformed JSON, non-object roots and oversized input', () {
      expect(
        LevelConfigValidator.validate('{not json', source: ConfigSource.cached)
            .firstError,
        'parse_error',
      );
      expect(
        LevelConfigValidator.validate('[1,2]', source: ConfigSource.cached)
            .firstError,
        'invalid_root',
      );
      expect(
        LevelConfigValidator.validate(' ' * 70000, source: ConfigSource.cached)
            .firstError,
        'too_large',
      );
    });

    test('rejects a blank gem or sub name', () {
      final gemName = _fixture();
      ((gemName['levels'] as Map<String, dynamic>)['ruby']
          as Map<String, dynamic>)['name'] = ' ';
      expect(_validate(gemName).firstError, 'invalid_gem_name:ruby');

      final subName = _fixture();
      _sub(subName, 'ruby', 'bling')['name'] = 5;
      expect(_validate(subName).firstError, 'invalid_sub_name:ruby.bling');
    });

    test('a bad background url drops only that level URL (BR1.3)', () {
      final cfg = _fixture();
      _sub(cfg, 'amethyst', 'shaping')['background_url'] =
          'https://evil.example.com/x.jpg';
      _sub(cfg, 'emerald', 'bling')['background_url'] = 42;
      final result = _validate(cfg);
      expect(result.isValid, isTrue);
      final config = result.config!;
      expect(config.levels['amethyst']!.subLevels['shaping']!.backgroundUrl,
          isNull);
      // URL hợp lệ của level khác vẫn còn.
      expect(
        config.levels['rose_quartz']!.subLevels['rough_stone']!.backgroundUrl,
        isNotNull,
      );
      expect(result.warnings, contains('background_url_rejected:amethyst.shaping'));
      expect(result.warnings, contains('background_url_rejected:emerald.bling'));
      expect(result.warnings.any((w) => w.contains('https://')), isFalse);
    });

    test('a blank background url is treated as absent without a warning', () {
      final cfg = _fixture();
      _sub(cfg, 'amethyst', 'shaping')['background_url'] = '  ';
      final result = _validate(cfg);
      expect(result.isValid, isTrue);
      expect(result.warnings.where((w) => w.startsWith('background_url')),
          isEmpty);
    });

    test('non-increasing targets only produce a warning (BR1.6)', () {
      final cfg = _fixture();
      _sub(cfg, 'rose_quartz', 'slabbing')['target_score'] = 400;
      final result = _validate(cfg);
      expect(result.isValid, isTrue);
      expect(result.warnings, contains('non_increasing_target:2'));
    });
  });

  group('LevelConfig', () {
    test('withSource keeps the data and swaps only the source', () {
      final config = _validate(_fixture()).config!;
      final cached = config.withSource(ConfigSource.cached);
      expect(cached.source, ConfigSource.cached);
      expect(cached.levels, same(config.levels));
      expect(ConfigSource.defaults.label, 'default');
      expect(ConfigSource.remote.label, 'remote');
    });
  });
}
