import 'package:block_blast/core/config/level_config.dart';
import 'package:block_blast/core/firebase/default_level_config.dart';
import 'package:block_blast/features/journey/models/level.dart';
import 'package:block_blast/features/journey/services/level_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LevelCatalog catalog;

  setUp(() {
    catalog = LevelCatalog.from(DefaultLevelConfig.config);
  });

  group('LevelCatalog', () {
    test('contains exactly 36 levels indexed 1..36 in order (BR2.1)', () {
      expect(catalog.levels.length, 36);
      expect(
        catalog.levels.map((l) => l.levelIndex),
        List<int>.generate(36, (i) => i + 1),
      );
    });

    test('levelIndex follows (gemOrder - 1) * 6 + subOrder', () {
      for (final level in catalog.levels) {
        expect(level.levelIndex, (level.gemOrder - 1) * 6 + level.subOrder);
      }
      final first = catalog.byIndex(1);
      expect(first.gemId, 'rose_quartz');
      expect(first.subId, 'rough_stone');
      expect(first.targetScore, 500);
      final last = catalog.byIndex(36);
      expect(last.gemId, 'ruby');
      expect(last.subId, 'bling');
      expect(last.targetScore, 350000);
    });

    test('assetPath is assets/design/Level<gem>/<sub>.jpg (BR2.3)', () {
      expect(catalog.byIndex(1).assetPath, 'assets/design/Level1/1.jpg');
      expect(catalog.byIndex(14).assetPath, 'assets/design/Level3/2.jpg');
      expect(catalog.byIndex(36).assetPath, 'assets/design/Level6/6.jpg');
    });

    test('next returns the following level and null at level 36 (BR2.2)', () {
      expect(catalog.next(catalog.byIndex(1))!.levelIndex, 2);
      expect(catalog.next(catalog.byIndex(6))!.levelIndex, 7);
      expect(catalog.next(catalog.byIndex(35))!.levelIndex, 36);
      expect(catalog.next(catalog.byIndex(36)), isNull);
    });

    test('the level list is unmodifiable (BR2.4)', () {
      expect(
        () => catalog.levels.add(catalog.levels.first),
        throwsUnsupportedError,
      );
      expect(() => catalog.levels.removeAt(0), throwsUnsupportedError);
    });

    test(
      'a catalog built earlier is not changed by a later config (BR2.4)',
      () {
        final before = catalog.byIndex(1).targetScore;
        LevelCatalog.from(
          DefaultLevelConfig.config.withSource(ConfigSource.remote),
        );
        expect(catalog.byIndex(1).targetScore, before);
      },
    );

    test('byIndex rejects out-of-range values; byIndexOr falls back', () {
      expect(() => catalog.byIndex(0), throwsRangeError);
      expect(() => catalog.byIndex(37), throwsRangeError);
      final fallback = catalog.byIndex(1);
      expect(catalog.byIndexOr(99, fallback), same(fallback));
      expect(catalog.byIndexOr(5, fallback).levelIndex, 5);
    });

    test('firstSubOf, isBling and isFinal identify structural levels', () {
      expect(catalog.firstSubOf('amethyst').levelIndex, 7);
      expect(catalog.isBling(catalog.byIndex(6)), isTrue);
      expect(catalog.isBling(catalog.byIndex(5)), isFalse);
      expect(catalog.isFinal(catalog.byIndex(36)), isTrue);
      expect(catalog.isFinal(catalog.byIndex(35)), isFalse);
    });

    test('displayName joins gem and sub names; isFinal flag on Level', () {
      expect(catalog.byIndex(1).displayName, 'Rose Quartz · Rough Stone');
      expect(catalog.byIndex(36).isFinal, isTrue);
      expect(catalog.byIndex(1).isFinal, isFalse);
      expect(Level.indexOf(2, 3), 9);
    });
  });
}
