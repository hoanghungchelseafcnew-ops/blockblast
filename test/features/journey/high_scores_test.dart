import 'dart:convert';

import 'package:block_blast/features/journey/models/high_scores.dart';
import 'package:block_blast/features/journey/models/player_progress.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/log_capture.dart';

void main() {
  late LogCapture log;

  setUp(() {
    log = LogCapture()..start();
  });

  group('HighScores.tryParse (E3, FR8.3)', () {
    test('a valid map is read per level', () {
      final scores = HighScores.tryParse(jsonEncode({'1': 1300, '7': 0}))!;
      expect(scores.of(1), 1300);
      expect(scores.of(7), 0);
      expect(scores.of(2), 0);
      expect(log.lines, isEmpty);
    });

    test('broken JSON or a non-object gives null', () {
      expect(HighScores.tryParse('{oops'), isNull);
      expect(log.where('high_scores json decode failed'), hasLength(1));
      expect(HighScores.tryParse('[1,2]'), isNull);
      expect(HighScores.tryParse(42), isNull);
      expect(HighScores.tryParse(null), isNull);
    });

    test('keys outside 1..36 and non-numeric keys are dropped', () {
      final scores = HighScores.tryParse(
        jsonEncode({'0': 5, '37': 5, 'abc': 5, '36': 9}),
      )!;
      expect(scores.asMap, {36: 9});
    });

    test('negative, fractional and string values are dropped', () {
      final scores = HighScores.tryParse(
        jsonEncode({'1': -1, '2': 2.5, '3': '400', '4': 400}),
      )!;
      expect(scores.asMap, {4: 400});
    });

    test('unknown nested fields are ignored instead of failing the key', () {
      final scores = HighScores.tryParse(
        jsonEncode({
          '5': 800,
          'meta': {'v': 2},
        }),
      )!;
      expect(scores.asMap, {5: 800});
    });
  });

  group('HighScores.withScore (FR2.3b, AC1.7.2)', () {
    test('a higher score replaces the old one', () {
      final scores = HighScores.empty.withScore(3, 500).withScore(3, 900);
      expect(scores.of(3), 900);
    });

    test('a lower or equal score keeps the same instance', () {
      final scores = HighScores.empty.withScore(3, 900);
      expect(identical(scores.withScore(3, 400), scores), isTrue);
      expect(identical(scores.withScore(3, 900), scores), isTrue);
      expect(scores.of(3), 900);
    });

    test('an index outside 1..36 is ignored', () {
      expect(
        identical(HighScores.empty.withScore(0, 10), HighScores.empty),
        isTrue,
      );
      expect(
        identical(HighScores.empty.withScore(37, 10), HighScores.empty),
        isTrue,
      );
    });

    test('toJsonString round-trips through tryParse', () {
      final scores = HighScores.empty.withScore(12, 70).withScore(2, 30);
      final again = HighScores.tryParse(scores.toJsonString())!;
      expect(again.asMap, {2: 30, 12: 70});
      expect(scores.toJsonString(), '{"2":30,"12":70}');
    });

    test('the map view cannot be modified', () {
      final scores = HighScores.empty.withScore(1, 10);
      expect(() => scores.asMap[1] = 99, throwsUnsupportedError);
    });
  });

  group('PlayerProgress.withoutGem (FR2.3a)', () {
    final progress = PlayerProgress.initial.copyWith(
      currentLevelIndex: 9,
      completedLevels: {1, 2, 3, 4, 5, 6, 7, 8},
      unlockedGems: {'rose_quartz'},
      highestLevelReached: 9,
    );

    test('removes exactly the six sub-levels of that gem', () {
      final result = progress.withoutGem(2);
      expect(result.completedLevels, {1, 2, 3, 4, 5, 6});
    });

    test('keeps every other field', () {
      final result = progress.withoutGem(2);
      expect(result.currentLevelIndex, 9);
      expect(result.unlockedGems, {'rose_quartz'});
      expect(result.highestLevelReached, 9);
      expect(result.journeyCompleted, isFalse);
    });

    test('a gem with no completed sub-level is unchanged', () {
      expect(progress.withoutGem(4).completedLevels, progress.completedLevels);
    });

    test('the last gem covers levels 31..36', () {
      final full = PlayerProgress.initial.copyWith(
        completedLevels: {for (var i = 1; i <= 36; i++) i},
      );
      expect(full.withoutGem(6).completedLevels, {
        for (var i = 1; i <= 30; i++) i,
      });
    });
  });
}
