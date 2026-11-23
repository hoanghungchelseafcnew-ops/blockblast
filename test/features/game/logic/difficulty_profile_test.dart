import 'package:block_blast/features/game/logic/difficulty_constants.dart';
import 'package:block_blast/features/game/logic/difficulty_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const profile = DifficultyProfile();

  group('DifficultyProfile', () {
    test('level 1 on an empty board uses 40/45/15 and 30% rescue', () {
      final r = profile.ratesFor(level: 1, filledCells: 0);
      expect(r.smallRate, closeTo(0.40, 1e-9));
      expect(r.mediumRate, closeTo(0.45, 1e-9));
      expect(r.largeRate, closeTo(0.15, 1e-9));
      expect(r.rescueRate, closeTo(0.30, 1e-9));
    });

    test('level 36 on an empty board uses 25/45/30 and 10% rescue', () {
      final r = profile.ratesFor(level: 36, filledCells: 0);
      expect(r.smallRate, closeTo(0.25, 1e-9));
      expect(r.mediumRate, closeTo(0.45, 1e-9));
      expect(r.largeRate, closeTo(0.30, 1e-9));
      expect(r.rescueRate, closeTo(0.10, 1e-9));
    });

    test('later levels have more large blocks and less rescue (AC4.4)', () {
      final first = profile.ratesFor(level: 1, filledCells: 0);
      final last = profile.ratesFor(level: 36, filledCells: 0);
      expect(last.largeRate, greaterThan(first.largeRate));
      expect(last.rescueRate, lessThan(first.rescueRate));
    });

    test('Endless level 18 sits between level 1 and level 36', () {
      final mid = profile.ratesFor(
        level: DifficultyConstants.endlessLevel,
        filledCells: 0,
      );
      expect(mid.largeRate, closeTo(0.15 + 0.15 * 17 / 35, 1e-9));
      expect(mid.rescueRate, closeTo(0.30 - 0.20 * 17 / 35, 1e-9));
    });

    test('a board over 60% full shifts weight to small blocks (AC4.3.1)', () {
      final r = profile.ratesFor(level: 1, filledCells: 39);
      expect(r.smallRate, closeTo(0.65, 1e-9));
      expect(r.largeRate, closeTo(0.06, 1e-9));
      expect(r.mediumRate, closeTo(0.29, 1e-9));
      final normal = profile.ratesFor(level: 1, filledCells: 0);
      expect(r.smallRate, greaterThan(normal.smallRate));
      expect(r.largeRate, lessThan(normal.largeRate));
    });

    test('exactly 38 filled cells still uses the normal rates (AC4.3.2)', () {
      final atThreshold = profile.ratesFor(level: 1, filledCells: 38);
      final empty = profile.ratesFor(level: 1, filledCells: 0);
      expect(atThreshold.smallRate, empty.smallRate);
      expect(atThreshold.largeRate, empty.largeRate);
    });

    test('the three size rates always sum to 1', () {
      for (var level = 1; level <= 36; level++) {
        for (final filled in [0, 38, 39, 64]) {
          final r = profile.ratesFor(level: level, filledCells: filled);
          expect(r.smallRate + r.mediumRate + r.largeRate, closeTo(1, 1e-9));
          expect(r.mediumRate, greaterThanOrEqualTo(0));
        }
      }
    });

    test('levels outside 1..36 are clamped', () {
      final low = profile.ratesFor(level: -5, filledCells: 0);
      final high = profile.ratesFor(level: 500, filledCells: 0);
      expect(low.rescueRate, closeTo(0.30, 1e-9));
      expect(high.rescueRate, closeTo(0.10, 1e-9));
    });
  });
}
