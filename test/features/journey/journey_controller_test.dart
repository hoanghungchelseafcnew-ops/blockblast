import 'package:block_blast/core/firebase/default_level_config.dart';
import 'package:block_blast/features/journey/controllers/journey_controller.dart';
import 'package:block_blast/features/journey/models/player_progress.dart';
import 'package:block_blast/features/journey/services/level_catalog.dart';
import 'package:block_blast/features/journey/services/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_progress_store.dart';
import '../../fakes/log_capture.dart';

class _Harness {
  _Harness(this.store, this.repo, this.catalog, this.journey);

  final FakeProgressStore store;
  final ProgressRepository repo;
  final LevelCatalog catalog;
  final JourneyController journey;

  static Future<_Harness> create({PlayerProgress? progress}) async {
    final store = FakeProgressStore();
    final repo = ProgressRepository(store);
    await repo.load();
    if (progress != null) await repo.savePlayerProgress(progress);
    final catalog = LevelCatalog.from(DefaultLevelConfig.config);
    return _Harness(
      store,
      repo,
      catalog,
      JourneyController(repository: repo, catalog: catalog),
    );
  }
}

PlayerProgress _at(int current, {Set<int>? completed, int? highest}) =>
    PlayerProgress(
      currentLevelIndex: current,
      completedLevels: completed ?? {for (var i = 1; i < current; i++) i},
      unlockedGems: const {},
      journeyCompleted: false,
      highestLevelReached: highest ?? current,
    );

void main() {
  setUp(() => LogCapture().start());

  group('JourneyController.onLevelWon (BR4.1..BR4.3)', () {
    test(
      'first win of level 5 moves to level 6 and raises highest to 6',
      () async {
        final h = await _Harness.create(progress: _at(5));
        final outcome = await h.journey.onLevelWon(h.catalog.byIndex(5), 1700);
        expect(outcome.nextLevel!.levelIndex, 6);
        expect(outcome.highestLevelReached, 6);
        expect(outcome.unlockedGemId, isNull);
        expect(outcome.journeyCompleted, isFalse);
        expect(h.repo.progress.currentLevelIndex, 6);
        expect(h.repo.progress.completedLevels, {1, 2, 3, 4, 5});
        final saved = PlayerProgress.tryParse(h.store.data['progress'])!;
        expect(saved.currentLevelIndex, 6);
        expect(saved.highestLevelReached, 6);
      },
    );

    test('winning level 5 again with highest=9 keeps highest at 9', () async {
      final h = await _Harness.create(
        progress: _at(5, completed: {1, 2, 3, 4}, highest: 9),
      );
      final outcome = await h.journey.onLevelWon(h.catalog.byIndex(5), 1700);
      expect(outcome.nextLevel!.levelIndex, 6);
      expect(outcome.highestLevelReached, 9);
      expect(h.repo.progress.currentLevelIndex, 6);
      expect(h.repo.progress.highestLevelReached, 9);
    });

    test(
      'winning level 36 completes the journey with no next level (C1)',
      () async {
        final h = await _Harness.create(progress: _at(36));
        final outcome = await h.journey.onLevelWon(
          h.catalog.byIndex(36),
          400000,
        );
        expect(outcome.nextLevel, isNull);
        expect(outcome.highestLevelReached, 36);
        expect(outcome.journeyCompleted, isTrue);
        expect(outcome.unlockedGemId, 'ruby');
        expect(h.repo.progress.currentLevelIndex, 36);
        expect(h.repo.progress.completedLevels, contains(36));
        expect(h.repo.progress.journeyCompleted, isTrue);
        expect(h.journey.journeyCompleted, isTrue);
        final saved = PlayerProgress.tryParse(h.store.data['progress'])!;
        expect(saved.journeyCompleted, isTrue);
      },
    );

    test(
      'winning Bling of gem 1 unlocks it and moves to gem 2 (AC1.3.1)',
      () async {
        final h = await _Harness.create(progress: _at(6));
        final outcome = await h.journey.onLevelWon(h.catalog.byIndex(6), 2000);
        expect(outcome.unlockedGemId, 'rose_quartz');
        expect(outcome.journeyCompleted, isFalse);
        expect(outcome.nextLevel!.gemId, 'amethyst');
        expect(outcome.nextLevel!.subOrder, 1);
        expect(h.repo.progress.unlockedGems, {'rose_quartz'});
        final saved = PlayerProgress.tryParse(h.store.data['progress'])!;
        expect(saved.unlockedGems, {'rose_quartz'});
      },
    );

    test('next level is correct for all 36 levels, gem changes included '
        '(FR2.5)', () async {
      final h = await _Harness.create();
      for (var k = 1; k <= 36; k++) {
        final outcome = await h.journey.onLevelWon(h.catalog.byIndex(k), 1);
        if (k == 36) {
          expect(outcome.nextLevel, isNull);
        } else {
          expect(outcome.nextLevel!.levelIndex, k + 1, reason: 'after $k');
        }
        expect(outcome.unlockedGemId != null, k % 6 == 0, reason: 'after $k');
      }
      expect(h.repo.progress.unlockedGems, hasLength(6));
      expect(h.repo.progress.completedLevels, hasLength(36));
    });

    test(
      'a win saves the level high score only when it is higher (AC1.7.2)',
      () async {
        final h = await _Harness.create(progress: _at(4));
        await h.journey.onLevelWon(h.catalog.byIndex(4), 1300);
        expect(h.repo.highScore(4), 1300);
        expect(h.journey.bestScoreFor(h.catalog.byIndex(4)), 1300);
        await h.journey.onLevelWon(h.catalog.byIndex(4), 900);
        expect(h.repo.highScore(4), 1300);
      },
    );

    test(
      'completedLevels is a set: adding the same level twice changes nothing',
      () async {
        final h = await _Harness.create(progress: _at(3));
        await h.journey.onLevelWon(h.catalog.byIndex(3), 100);
        final afterFirst = Set<int>.of(h.repo.progress.completedLevels);
        await h.journey.onLevelWon(h.catalog.byIndex(3), 100);
        expect(h.repo.progress.completedLevels, afterFirst);
        expect(h.repo.progress.completedLevels.length, 3);
      },
    );

    test('a write failure still returns the outcome and marks dirty', () async {
      final h = await _Harness.create(progress: _at(2));
      h.store.failingKeys.add('progress');
      final outcome = await h.journey.onLevelWon(h.catalog.byIndex(2), 900);
      expect(outcome.nextLevel!.levelIndex, 3);
      expect(outcome.highestLevelReached, 3);
      expect(h.repo.progress.currentLevelIndex, 3);
      expect(h.repo.dirtyKeys, {'progress'});
    });

    test(
      'the cache is updated synchronously, before the write completes',
      () async {
        final h = await _Harness.create(progress: _at(2));
        h.store.writeDelay['progress'] = const Duration(milliseconds: 40);
        final pending = h.journey.onLevelWon(h.catalog.byIndex(2), 900);
        expect(h.repo.progress.currentLevelIndex, 3);
        expect(
          h.journey.outcomeFor(h.catalog.byIndex(2)).nextLevel!.levelIndex,
          3,
        );
        await pending;
      },
    );

    test('never throws when the repository is read-only', () async {
      final store = FakeProgressStore()..initAlwaysFails = true;
      final repo = ProgressRepository(store);
      await repo.load();
      final catalog = LevelCatalog.from(DefaultLevelConfig.config);
      final journey = JourneyController(repository: repo, catalog: catalog);
      final outcome = await journey.onLevelWon(catalog.byIndex(1), 600);
      expect(outcome.nextLevel!.levelIndex, 2);
      expect(store.attempts, isEmpty);
    });
  });

  group('JourneyController.onLevelLost (FR2.3, FR2.3a, FR2.3b, FR2.4)', () {
    // Amethyst = gem 2 (levels 7..12); Shaping = sub 3 → level 9.
    test('losing at Amethyst · Shaping returns to Amethyst · Rough Stone '
        '(AC1.4.1, AC1.4.2)', () async {
      final h = await _Harness.create(progress: _at(9));
      final outcome = await h.journey.onLevelLost(h.catalog.byIndex(9), 2850);
      expect(outcome.nextLevel!.levelIndex, 7);
      expect(outcome.nextLevel!.displayName, 'Amethyst · Rough Stone');
      expect(outcome.unlockedGemId, isNull);
      expect(outcome.journeyCompleted, isFalse);
      expect(h.repo.progress.currentLevelIndex, 7);
      expect(h.repo.progress.completedLevels, {1, 2, 3, 4, 5, 6});
      final saved = PlayerProgress.tryParse(h.store.data['progress'])!;
      expect(saved.currentLevelIndex, 7);
      expect(saved.completedLevels, {1, 2, 3, 4, 5, 6});
    });

    test('losing at a Rough Stone stays there and keeps earlier gems '
        '(AC1.4.3, AC1.4.4)', () async {
      final h = await _Harness.create(
        progress: _at(7, completed: {1, 2, 3, 4, 5, 6}),
      );
      await h.repo.saveHighScore(7, 3000);
      final outcome = await h.journey.onLevelLost(h.catalog.byIndex(7), 120);
      expect(outcome.nextLevel!.levelIndex, 7);
      expect(h.repo.progress.currentLevelIndex, 7);
      expect(h.repo.progress.completedLevels, {1, 2, 3, 4, 5, 6});
      expect(h.repo.highScore(7), 3000, reason: 'high score is kept');
    });

    test('highestLevelReached and unlocked gems never go down', () async {
      final h = await _Harness.create(
        progress: _at(9, highest: 20).copyWith(unlockedGems: {'rose_quartz'}),
      );
      final outcome = await h.journey.onLevelLost(h.catalog.byIndex(9), 10);
      expect(outcome.highestLevelReached, 20);
      expect(h.repo.progress.highestLevelReached, 20);
      expect(h.repo.progress.unlockedGems, {'rose_quartz'});
    });

    test(
      'a loss with a new best score updates high_scores (AC1.7.2)',
      () async {
        final h = await _Harness.create(progress: _at(9));
        await h.journey.onLevelLost(h.catalog.byIndex(9), 2850);
        expect(h.repo.highScore(9), 2850);
        await h.journey.onLevelLost(h.catalog.byIndex(9), 100);
        expect(h.repo.highScore(9), 2850);
      },
    );

    test(
      'a write failure still returns the outcome without throwing',
      () async {
        final h = await _Harness.create(progress: _at(9));
        h.store.failingKeys.addAll({'progress', 'high_scores'});
        final outcome = await h.journey.onLevelLost(h.catalog.byIndex(9), 50);
        expect(outcome.nextLevel!.levelIndex, 7);
        expect(h.repo.progress.currentLevelIndex, 7);
        expect(h.repo.dirtyKeys, {'progress', 'high_scores'});
      },
    );

    test(
      'lostOutcomeFor and returnLevelFor work from the cache only',
      () async {
        final h = await _Harness.create(progress: _at(33));
        h.store.attempts.clear();
        final level = h.catalog.byIndex(33);
        expect(h.journey.returnLevelFor(level).levelIndex, 31);
        final outcome = h.journey.lostOutcomeFor(level);
        expect(outcome.nextLevel!.levelIndex, 31);
        expect(outcome.highestLevelReached, 33);
        expect(h.store.attempts, isEmpty);
      },
    );
  });

  group('JourneyController state', () {
    test(
      'currentLevel follows the saved progress and starts at level 1',
      () async {
        final fresh = await _Harness.create();
        expect(fresh.journey.currentLevel.levelIndex, 1);
        expect(fresh.journey.journeyCompleted, isFalse);
        final saved = await _Harness.create(progress: _at(12));
        expect(saved.journey.currentLevel.levelIndex, 12);
      },
    );
  });
}
