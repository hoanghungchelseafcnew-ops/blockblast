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
    test('first win of level 5 moves to level 6 and raises highest to 6',
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
    });

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

    test('winning level 36 keeps the player on 36 with no next level', () async {
      final h = await _Harness.create(progress: _at(36));
      final outcome = await h.journey.onLevelWon(h.catalog.byIndex(36), 400000);
      expect(outcome.nextLevel, isNull);
      expect(outcome.highestLevelReached, 36);
      expect(outcome.journeyCompleted, isFalse);
      expect(h.repo.progress.currentLevelIndex, 36);
      expect(h.repo.progress.completedLevels, contains(36));
      expect(h.repo.progress.journeyCompleted, isFalse);
    });

    test('completedLevels is a set: adding the same level twice changes nothing',
        () async {
      final h = await _Harness.create(progress: _at(3));
      await h.journey.onLevelWon(h.catalog.byIndex(3), 100);
      final afterFirst = Set<int>.of(h.repo.progress.completedLevels);
      await h.journey.onLevelWon(h.catalog.byIndex(3), 100);
      expect(h.repo.progress.completedLevels, afterFirst);
      expect(h.repo.progress.completedLevels.length, 3);
    });

    test('a write failure still returns the outcome and marks dirty', () async {
      final h = await _Harness.create(progress: _at(2));
      h.store.failingKeys.add('progress');
      final outcome = await h.journey.onLevelWon(h.catalog.byIndex(2), 900);
      expect(outcome.nextLevel!.levelIndex, 3);
      expect(outcome.highestLevelReached, 3);
      expect(h.repo.progress.currentLevelIndex, 3);
      expect(h.repo.dirtyKeys, {'progress'});
    });

    test('the cache is updated synchronously, before the write completes',
        () async {
      final h = await _Harness.create(progress: _at(2));
      h.store.writeDelay['progress'] = const Duration(milliseconds: 40);
      final pending = h.journey.onLevelWon(h.catalog.byIndex(2), 900);
      expect(h.repo.progress.currentLevelIndex, 3);
      expect(h.journey.outcomeFor(h.catalog.byIndex(2)).nextLevel!.levelIndex, 3);
      await pending;
    });

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

  group('JourneyController state', () {
    test('currentLevel follows the saved progress and starts at level 1',
        () async {
      final fresh = await _Harness.create();
      expect(fresh.journey.currentLevel.levelIndex, 1);
      expect(fresh.journey.journeyCompleted, isFalse);
      final saved = await _Harness.create(progress: _at(12));
      expect(saved.journey.currentLevel.levelIndex, 12);
    });
  });
}
