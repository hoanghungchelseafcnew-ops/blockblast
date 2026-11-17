import 'dart:convert';

import 'package:block_blast/features/journey/models/player_progress.dart';
import 'package:block_blast/features/journey/services/progress_repository.dart';
import 'package:block_blast/features/journey/services/progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fakes/fake_progress_store.dart';
import '../../fakes/log_capture.dart';

String _progressJson({
  Object? current = 3,
  Object? completed = const [1, 2],
  Object? highest = 3,
}) =>
    jsonEncode({
      'currentLevelIndex': current,
      'completedLevels': completed,
      'unlockedGems': <String>[],
      'journeyCompleted': false,
      'highestLevelReached': highest,
      'unknown_future_field': 'ignored',
    });

Future<ProgressRepository> _loaded(FakeProgressStore store) async {
  final repo = ProgressRepository(store);
  await repo.load();
  return repo;
}

void main() {
  late LogCapture log;

  setUp(() {
    log = LogCapture()..start();
  });

  const key = ProgressRepository.progressKey;
  const tut = ProgressRepository.tutorialKey;

  group('load (BR3.1, BR3.5)', () {
    test('missing keys give the defaults without any warning', () async {
      final repo = await _loaded(FakeProgressStore());
      expect(repo.progress.currentLevelIndex, 1);
      expect(repo.progress.highestLevelReached, 1);
      expect(repo.progress.completedLevels, isEmpty);
      expect(repo.tutorialCompleted, isFalse);
      expect(repo.isReadOnly, isFalse);
      expect(repo.isLoaded, isTrue);
      expect(log.lines, isEmpty);
    });

    test('a valid saved progress is restored, unknown fields ignored',
        () async {
      final repo = await _loaded(FakeProgressStore(initial: {
        key: _progressJson(current: 6, completed: [1, 2, 3, 4, 5], highest: 6),
        tut: true,
      }));
      expect(repo.progress.currentLevelIndex, 6);
      expect(repo.progress.completedLevels, {1, 2, 3, 4, 5});
      expect(repo.progress.highestLevelReached, 6);
      expect(repo.tutorialCompleted, isTrue);
    });

    test('corrupt JSON or wrong type falls back to level 1 with a log',
        () async {
      for (final bad in <Object>['{oops', '[1,2]', 42]) {
        log.lines.clear();
        final repo = await _loaded(FakeProgressStore(initial: {key: bad}));
        expect(repo.progress.currentLevelIndex, 1, reason: '$bad');
        expect(log.where('invalid'), hasLength(1), reason: '$bad');
        expect(repo.isReadOnly, isFalse);
      }
    });

    test('currentLevelIndex outside 1..36 resets the whole progress',
        () async {
      for (final bad in <Object>[0, 37, -3, '5', 2.5]) {
        final repo = await _loaded(FakeProgressStore(
          initial: {key: _progressJson(current: bad, completed: [1, 2])},
        ));
        expect(repo.progress.currentLevelIndex, 1, reason: '$bad');
        expect(repo.progress.completedLevels, isEmpty, reason: '$bad');
      }
    });

    test('completedLevels entries outside 1..36 or non-int are dropped',
        () async {
      final repo = await _loaded(FakeProgressStore(initial: {
        key: _progressJson(completed: [0, 1, 36, 37, 'x', 2.5, -1], highest: 3),
      }));
      expect(repo.progress.completedLevels, {1, 36});
    });

    test('highestLevelReached is max(read value, currentLevelIndex)', () async {
      final low = await _loaded(FakeProgressStore(
        initial: {key: _progressJson(current: 8, highest: 2)},
      ));
      expect(low.progress.highestLevelReached, 8);
      final invalid = await _loaded(FakeProgressStore(
        initial: {key: _progressJson(current: 4, highest: 99)},
      ));
      expect(invalid.progress.highestLevelReached, 4);
      final higher = await _loaded(FakeProgressStore(
        initial: {key: _progressJson(current: 4, highest: 9)},
      ));
      expect(higher.progress.highestLevelReached, 9);
    });

    test('a non-bool tutorial value counts as not seen, with a warning',
        () async {
      final repo = await _loaded(FakeProgressStore(initial: {tut: 'yes'}));
      expect(repo.tutorialCompleted, isFalse);
      expect(log.where(tut), hasLength(1));
      expect(repo.isReadOnly, isFalse);
    });

    test('a single failed init is retried once and then succeeds', () async {
      final store = FakeProgressStore(initial: {key: _progressJson(current: 5)})
        ..initFailures = 1;
      final repo = await _loaded(store);
      expect(store.initCalls, 2);
      expect(repo.progress.currentLevelIndex, 5);
      expect(repo.isReadOnly, isFalse);
    });

    test('two failed attempts enter read-only mode with defaults', () async {
      final store = FakeProgressStore()..initAlwaysFails = true;
      final repo = await _loaded(store);
      expect(store.initCalls, 2);
      expect(repo.isReadOnly, isTrue);
      expect(repo.progress.currentLevelIndex, 1);
      expect(log.where('read-only mode'), hasLength(1));
    });

    test('load is idempotent', () async {
      final store = FakeProgressStore();
      final repo = await _loaded(store);
      await repo.load();
      expect(store.initCalls, 1);
    });
  });

  group('writes (BR3.2, BR3.3)', () {
    test('savePlayerProgress updates the cache at once and persists',
        () async {
      final store = FakeProgressStore();
      final repo = await _loaded(store);
      final updated = PlayerProgress.initial.copyWith(
        currentLevelIndex: 2,
        completedLevels: {1},
        highestLevelReached: 2,
      );
      final future = repo.savePlayerProgress(updated);
      expect(repo.progress.currentLevelIndex, 2, reason: 'cache is synchronous');
      await future;
      final saved = PlayerProgress.tryParse(store.data[key]);
      expect(saved!.currentLevelIndex, 2);
      expect(saved.completedLevels, {1});
      expect(repo.dirtyKeys, isEmpty);
    });

    test('setTutorialCompleted writes a bool under the old key', () async {
      final store = FakeProgressStore();
      final repo = await _loaded(store);
      await repo.setTutorialCompleted(true);
      expect(repo.tutorialCompleted, isTrue);
      expect(store.data[tut], true);
    });

    test('writes run in FIFO order even when an earlier one is slower',
        () async {
      final store = FakeProgressStore()
        ..writeDelay[key] = const Duration(milliseconds: 40);
      final repo = await _loaded(store);
      final first = repo.savePlayerProgress(
        PlayerProgress.initial.copyWith(currentLevelIndex: 2),
      );
      final second = repo.setTutorialCompleted(true);
      final third = repo.savePlayerProgress(
        PlayerProgress.initial.copyWith(currentLevelIndex: 3),
      );
      await Future.wait([first, second, third]);
      expect(store.completed, [key, tut, key]);
      expect(PlayerProgress.tryParse(store.data[key])!.currentLevelIndex, 3);
    });

    test('writes issued before load wait for it (gate)', () async {
      final store = FakeProgressStore(initial: {key: _progressJson(current: 4)});
      final repo = ProgressRepository(store);
      final pending = repo.setTutorialCompleted(true);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(store.attempts, isEmpty, reason: 'nothing is written before load');
      await repo.load();
      await pending;
      expect(store.attempts, [tut]);
      expect(repo.progress.currentLevelIndex, 4);
    });

    test('a failed write keeps the cache, marks dirty and does not throw',
        () async {
      final store = FakeProgressStore()..failingKeys.add(key);
      final repo = await _loaded(store);
      await repo.savePlayerProgress(
        PlayerProgress.initial.copyWith(currentLevelIndex: 4, highestLevelReached: 4),
      );
      expect(repo.progress.currentLevelIndex, 4);
      expect(repo.dirtyKeys, {key});
      expect(log.where('marked dirty'), hasLength(1));
    });

    test('the next write of any key retries the dirty key first', () async {
      final store = FakeProgressStore()..failingKeys.add(key);
      final repo = await _loaded(store);
      await repo.savePlayerProgress(
        PlayerProgress.initial.copyWith(currentLevelIndex: 4, highestLevelReached: 4),
      );
      store.failingKeys.clear();
      store.attempts.clear();
      await repo.setTutorialCompleted(true);
      expect(store.attempts, [key, tut]);
      expect(repo.dirtyKeys, isEmpty);
      expect(PlayerProgress.tryParse(store.data[key])!.currentLevelIndex, 4);
    });

    test('automatic retries stop after 3 attempts per key', () async {
      final store = FakeProgressStore()..failingKeys.add(key);
      final repo = await _loaded(store);
      await repo.savePlayerProgress(PlayerProgress.initial);
      for (var i = 0; i < 6; i++) {
        await repo.setTutorialCompleted(i.isEven);
      }
      // 1 lần ghi gốc + đúng 3 lần tự thử lại.
      expect(store.attemptsFor(key), 4);
      expect(repo.dirtyKeys, {key});
    });

    test('flushDirty ignores the retry counter and clears dirty on success',
        () async {
      final store = FakeProgressStore()..failingKeys.add(key);
      final repo = await _loaded(store);
      await repo.savePlayerProgress(PlayerProgress.initial);
      for (var i = 0; i < 5; i++) {
        await repo.setTutorialCompleted(true);
      }
      final before = store.attemptsFor(key);
      store.failingKeys.clear();
      await repo.flushDirty();
      expect(store.attemptsFor(key), before + 1);
      expect(repo.dirtyKeys, isEmpty);
    });

    test('flushDirty with nothing dirty writes nothing', () async {
      final store = FakeProgressStore();
      final repo = await _loaded(store);
      await repo.flushDirty();
      expect(store.attempts, isEmpty);
    });

    test('a failing write does not break the queue for later writes', () async {
      final store = FakeProgressStore()..failingKeys.add(tut);
      final repo = await _loaded(store);
      await repo.setTutorialCompleted(true);
      await repo.savePlayerProgress(
        PlayerProgress.initial.copyWith(currentLevelIndex: 2),
      );
      expect(PlayerProgress.tryParse(store.data[key])!.currentLevelIndex, 2);
    });
  });

  group('read-only mode (D-R5)', () {
    test('writes are skipped and only the first skip logs a warning',
        () async {
      final store = FakeProgressStore()..initAlwaysFails = true;
      final repo = await _loaded(store);
      log.lines.clear();
      await repo.savePlayerProgress(
        PlayerProgress.initial.copyWith(currentLevelIndex: 2),
      );
      await repo.setTutorialCompleted(true);
      await repo.flushDirty();
      expect(store.attempts, isEmpty);
      expect(repo.progress.currentLevelIndex, 2, reason: 'cache still updates');
      expect(log.where('write skipped'), hasLength(1));
    });

    test('abandonLoad switches to read-only so real data is not overwritten',
        () async {
      final store = FakeProgressStore(initial: {key: _progressJson(current: 9)})
        ..initHangs = true;
      final repo = ProgressRepository(store);
      final loading = repo.load();
      repo.abandonLoad();
      expect(repo.isLoaded, isTrue);
      expect(repo.isReadOnly, isTrue);
      expect(repo.progress.currentLevelIndex, 1);
      await repo.savePlayerProgress(PlayerProgress.initial);
      expect(store.attempts, isEmpty);
      expect(log.where('load deadline'), hasLength(1));
      // load() cũ không bao giờ hoàn tất; không await.
      expect(loading, isA<Future<void>>());
    });

    test('abandonLoad after a completed load is a no-op', () async {
      final repo = await _loaded(FakeProgressStore());
      repo.abandonLoad();
      expect(repo.isReadOnly, isFalse);
    });

    test('a load that finishes after abandonLoad does not overwrite defaults',
        () async {
      final store = FakeProgressStore(initial: {key: _progressJson(current: 9)})
        ..initDelay = const Duration(milliseconds: 30);
      final repo = ProgressRepository(store);
      final loading = repo.load();
      repo.abandonLoad();
      await loading;
      expect(repo.progress.currentLevelIndex, 1);
      expect(repo.isReadOnly, isTrue);
    });
  });

  group('misc', () {
    test('highScore is 0 until U2', () async {
      final repo = await _loaded(FakeProgressStore());
      expect(repo.highScore(5), 0);
    });
  });

  group('SharedPreferencesProgressStore', () {
    test('round-trips string and bool values through SharedPreferences',
        () async {
      SharedPreferences.setMockInitialValues({tut: true});
      final store = SharedPreferencesProgressStore();
      await store.init();
      expect(store.read(tut), true);
      await store.writeString(key, 'abc');
      await store.writeBool(tut, false);
      expect(store.read(key), 'abc');
      expect(store.read(tut), false);
      expect(store.read('missing'), isNull);
    });

    test('reading before init throws a StateError', () {
      expect(() => SharedPreferencesProgressStore().read(key),
          throwsStateError);
    });

    test('the repository works end to end on top of SharedPreferences',
        () async {
      SharedPreferences.setMockInitialValues({
        key: _progressJson(current: 7, completed: [1, 2, 3, 4, 5, 6], highest: 7),
      });
      final repo = ProgressRepository(SharedPreferencesProgressStore());
      await repo.load();
      expect(repo.progress.currentLevelIndex, 7);
      await repo.savePlayerProgress(
        repo.progress.copyWith(currentLevelIndex: 8, highestLevelReached: 8),
      );
      final reloaded = ProgressRepository(SharedPreferencesProgressStore());
      await reloaded.load();
      expect(reloaded.progress.currentLevelIndex, 8);
    });
  });
}
