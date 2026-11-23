import 'dart:convert';

import 'package:block_blast/features/endless/models/endless_state.dart';
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
}) => jsonEncode({
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

    test(
      'a valid saved progress is restored, unknown fields ignored',
      () async {
        final repo = await _loaded(
          FakeProgressStore(
            initial: {
              key: _progressJson(
                current: 6,
                completed: [1, 2, 3, 4, 5],
                highest: 6,
              ),
              tut: true,
            },
          ),
        );
        expect(repo.progress.currentLevelIndex, 6);
        expect(repo.progress.completedLevels, {1, 2, 3, 4, 5});
        expect(repo.progress.highestLevelReached, 6);
        expect(repo.tutorialCompleted, isTrue);
      },
    );

    test(
      'corrupt JSON or wrong type falls back to level 1 with a log',
      () async {
        for (final bad in <Object>['{oops', '[1,2]', 42]) {
          log.lines.clear();
          final repo = await _loaded(FakeProgressStore(initial: {key: bad}));
          expect(repo.progress.currentLevelIndex, 1, reason: '$bad');
          expect(log.where('invalid'), hasLength(1), reason: '$bad');
          expect(repo.isReadOnly, isFalse);
        }
      },
    );

    test('currentLevelIndex outside 1..36 resets the whole progress', () async {
      for (final bad in <Object>[0, 37, -3, '5', 2.5]) {
        final repo = await _loaded(
          FakeProgressStore(
            initial: {
              key: _progressJson(current: bad, completed: [1, 2]),
            },
          ),
        );
        expect(repo.progress.currentLevelIndex, 1, reason: '$bad');
        expect(repo.progress.completedLevels, isEmpty, reason: '$bad');
      }
    });

    test(
      'completedLevels entries outside 1..36 or non-int are dropped',
      () async {
        final repo = await _loaded(
          FakeProgressStore(
            initial: {
              key: _progressJson(
                completed: [0, 1, 36, 37, 'x', 2.5, -1],
                highest: 3,
              ),
            },
          ),
        );
        expect(repo.progress.completedLevels, {1, 36});
      },
    );

    test('highestLevelReached is max(read value, currentLevelIndex)', () async {
      final low = await _loaded(
        FakeProgressStore(
          initial: {key: _progressJson(current: 8, highest: 2)},
        ),
      );
      expect(low.progress.highestLevelReached, 8);
      final invalid = await _loaded(
        FakeProgressStore(
          initial: {key: _progressJson(current: 4, highest: 99)},
        ),
      );
      expect(invalid.progress.highestLevelReached, 4);
      final higher = await _loaded(
        FakeProgressStore(
          initial: {key: _progressJson(current: 4, highest: 9)},
        ),
      );
      expect(higher.progress.highestLevelReached, 9);
    });

    test(
      'a non-bool tutorial value counts as not seen, with a warning',
      () async {
        final repo = await _loaded(FakeProgressStore(initial: {tut: 'yes'}));
        expect(repo.tutorialCompleted, isFalse);
        expect(log.where(tut), hasLength(1));
        expect(repo.isReadOnly, isFalse);
      },
    );

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
    test('savePlayerProgress updates the cache at once and persists', () async {
      final store = FakeProgressStore();
      final repo = await _loaded(store);
      final updated = PlayerProgress.initial.copyWith(
        currentLevelIndex: 2,
        completedLevels: {1},
        highestLevelReached: 2,
      );
      final future = repo.savePlayerProgress(updated);
      expect(
        repo.progress.currentLevelIndex,
        2,
        reason: 'cache is synchronous',
      );
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

    test(
      'writes run in FIFO order even when an earlier one is slower',
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
      },
    );

    test('writes issued before load wait for it (gate)', () async {
      final store = FakeProgressStore(
        initial: {key: _progressJson(current: 4)},
      );
      final repo = ProgressRepository(store);
      final pending = repo.setTutorialCompleted(true);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(store.attempts, isEmpty, reason: 'nothing is written before load');
      await repo.load();
      await pending;
      expect(store.attempts, [tut]);
      expect(repo.progress.currentLevelIndex, 4);
    });

    test(
      'a failed write keeps the cache, marks dirty and does not throw',
      () async {
        final store = FakeProgressStore()..failingKeys.add(key);
        final repo = await _loaded(store);
        await repo.savePlayerProgress(
          PlayerProgress.initial.copyWith(
            currentLevelIndex: 4,
            highestLevelReached: 4,
          ),
        );
        expect(repo.progress.currentLevelIndex, 4);
        expect(repo.dirtyKeys, {key});
        expect(log.where('marked dirty'), hasLength(1));
      },
    );

    test('the next write of any key retries the dirty key first', () async {
      final store = FakeProgressStore()..failingKeys.add(key);
      final repo = await _loaded(store);
      await repo.savePlayerProgress(
        PlayerProgress.initial.copyWith(
          currentLevelIndex: 4,
          highestLevelReached: 4,
        ),
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

    test(
      'flushDirty ignores the retry counter and clears dirty on success',
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
      },
    );

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
    test('writes are skipped and only the first skip logs a warning', () async {
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

    test(
      'abandonLoad switches to read-only so real data is not overwritten',
      () async {
        final store = FakeProgressStore(
          initial: {key: _progressJson(current: 9)},
        )..initHangs = true;
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
      },
    );

    test('abandonLoad after a completed load is a no-op', () async {
      final repo = await _loaded(FakeProgressStore());
      repo.abandonLoad();
      expect(repo.isReadOnly, isFalse);
    });

    test(
      'a load that finishes after abandonLoad does not overwrite defaults',
      () async {
        final store = FakeProgressStore(
          initial: {key: _progressJson(current: 9)},
        )..initDelay = const Duration(milliseconds: 30);
        final repo = ProgressRepository(store);
        final loading = repo.load();
        repo.abandonLoad();
        await loading;
        expect(repo.progress.currentLevelIndex, 1);
        expect(repo.isReadOnly, isTrue);
      },
    );
  });

  group('high scores (C5, E3, AC1.7.2)', () {
    const hs = ProgressRepository.highScoresKey;

    test('a missing key gives no scores without a warning', () async {
      final repo = await _loaded(FakeProgressStore());
      expect(repo.highScore(5), 0);
      expect(repo.highScores.asMap, isEmpty);
      expect(log.lines, isEmpty);
    });

    test('saved scores are read per level', () async {
      final repo = await _loaded(
        FakeProgressStore(
          initial: {
            hs: jsonEncode({'5': 1300, '6': 200}),
          },
        ),
      );
      expect(repo.highScore(5), 1300);
      expect(repo.highScore(6), 200);
      expect(repo.highScore(7), 0);
    });

    test('a corrupt key resets only high scores, with a warning', () async {
      final repo = await _loaded(
        FakeProgressStore(
          initial: {hs: '{oops', key: _progressJson(current: 4)},
        ),
      );
      expect(repo.highScore(1), 0);
      expect(repo.progress.currentLevelIndex, 4);
      expect(log.where('key $hs invalid'), hasLength(1));
      expect(repo.isReadOnly, isFalse);
    });

    test(
      'saveHighScore persists a higher score and skips a lower one',
      () async {
        final store = FakeProgressStore();
        final repo = await _loaded(store);
        await repo.saveHighScore(3, 900);
        expect(jsonDecode(store.data[hs]! as String), {'3': 900});
        store.attempts.clear();
        await repo.saveHighScore(3, 400);
        expect(store.attempts, isEmpty);
        expect(repo.highScore(3), 900);
      },
    );

    test('high score writes share the FIFO queue with progress', () async {
      final store = FakeProgressStore()
        ..writeDelay[key] = const Duration(milliseconds: 30);
      final repo = await _loaded(store);
      final a = repo.savePlayerProgress(
        PlayerProgress.initial.copyWith(currentLevelIndex: 2),
      );
      final b = repo.saveHighScore(1, 700);
      await Future.wait([a, b]);
      expect(store.completed, [key, hs]);
    });

    test(
      'a failed write marks high_scores dirty and the next write retries',
      () async {
        final store = FakeProgressStore()..failingKeys.add(hs);
        final repo = await _loaded(store);
        await repo.saveHighScore(2, 500);
        expect(repo.dirtyKeys, {hs});
        expect(repo.highScore(2), 500, reason: 'the cache keeps the value');
        store.failingKeys.clear();
        store.attempts.clear();
        await repo.setTutorialCompleted(true);
        expect(store.attempts, [hs, tut]);
        expect(repo.dirtyKeys, isEmpty);
        expect(jsonDecode(store.data[hs]! as String), {'2': 500});
      },
    );

    test('flushDirty writes a dirty high_scores key', () async {
      final store = FakeProgressStore()..failingKeys.add(hs);
      final repo = await _loaded(store);
      await repo.saveHighScore(9, 50);
      store.failingKeys.clear();
      await repo.flushDirty();
      expect(repo.dirtyKeys, isEmpty);
      expect(jsonDecode(store.data[hs]! as String), {'9': 50});
    });

    test(
      'read-only mode keeps high scores in memory but writes nothing',
      () async {
        final store = FakeProgressStore()..initAlwaysFails = true;
        final repo = await _loaded(store);
        await repo.saveHighScore(1, 100);
        expect(repo.highScore(1), 100);
        expect(store.attempts, isEmpty);
      },
    );
  });

  group('endless keys (C5, E3, ER13)', () {
    const saved = ProgressRepository.endlessSavedKey;
    const high = ProgressRepository.endlessHighKey;

    test('missing keys give 0 / 0 without a warning', () async {
      final repo = await _loaded(FakeProgressStore());
      expect(repo.endlessState, EndlessState.initial);
      expect(log.lines, isEmpty);
    });

    test('saved values are read back', () async {
      final repo = await _loaded(
        FakeProgressStore(initial: {saved: 1200, high: 12400}),
      );
      expect(
        repo.endlessState,
        const EndlessState(savedScore: 1200, highScore: 12400),
      );
    });

    test('negative or wrongly typed values become 0 with a warning', () async {
      final repo = await _loaded(
        FakeProgressStore(initial: {saved: -1, high: '900'}),
      );
      expect(repo.endlessState, EndlessState.initial);
      expect(log.where('key $saved invalid'), hasLength(1));
      expect(log.where('key $high invalid'), hasLength(1));
    });

    test('saveEndlessState survives a restart, 0 included (AC4.2.3)',
        () async {
      final store = FakeProgressStore();
      final repo = await _loaded(store);
      await repo.saveEndlessState(
        const EndlessState(savedScore: 1200, highScore: 3000),
      );
      expect(store.data[saved], 1200);
      expect(store.data[high], 3000);
      await repo.saveEndlessState(const EndlessState(highScore: 3000));
      expect(store.data[saved], 0);
      final restarted = await _loaded(FakeProgressStore(initial: store.data));
      expect(restarted.endlessState, const EndlessState(highScore: 3000));
    });

    test('a failed write is marked dirty and retried later', () async {
      final store = FakeProgressStore()..failingKeys.add(saved);
      final repo = await _loaded(store);
      await repo.saveEndlessState(const EndlessState(savedScore: 50));
      expect(repo.dirtyKeys, {saved});
      expect(repo.endlessState.savedScore, 50);
      store.failingKeys.clear();
      await repo.flushDirty();
      expect(store.data[saved], 50);
      expect(repo.dirtyKeys, isEmpty);
    });

    test('read-only mode keeps the state in memory only', () async {
      final store = FakeProgressStore()..initAlwaysFails = true;
      final repo = await _loaded(store);
      await repo.saveEndlessState(const EndlessState(savedScore: 7));
      expect(repo.endlessState.savedScore, 7);
      expect(store.attempts, isEmpty);
    });
  });

  group('total_play_time (C5, E3, AC1.6.2)', () {
    const tp = ProgressRepository.totalPlayTimeKey;

    test('a missing key is 0 without a warning', () async {
      final repo = await _loaded(FakeProgressStore());
      expect(repo.totalPlayTime, 0);
      expect(log.lines, isEmpty);
    });

    test('a negative or wrongly typed value is 0, with a warning', () async {
      for (final bad in <Object>[-3, '12', 1.5]) {
        log.lines.clear();
        final repo = await _loaded(FakeProgressStore(initial: {tp: bad}));
        expect(repo.totalPlayTime, 0, reason: '$bad');
        expect(log.where('key $tp invalid'), hasLength(1), reason: '$bad');
      }
    });

    test('addPlayTime adds up and survives a restart', () async {
      final store = FakeProgressStore(initial: {tp: 100});
      final repo = await _loaded(store);
      await repo.addPlayTime(30);
      await repo.addPlayTime(12);
      expect(repo.totalPlayTime, 142);
      expect(store.data[tp], 142);
      final restarted = await _loaded(FakeProgressStore(initial: store.data));
      expect(restarted.totalPlayTime, 142);
    });

    test('zero or negative seconds are ignored', () async {
      final store = FakeProgressStore();
      final repo = await _loaded(store);
      await repo.addPlayTime(0);
      await repo.addPlayTime(-8);
      expect(repo.totalPlayTime, 0);
      expect(store.attempts, isEmpty);
    });

    test('a failed write is retried on the next write', () async {
      final store = FakeProgressStore()..failingKeys.add(tp);
      final repo = await _loaded(store);
      await repo.addPlayTime(20);
      expect(repo.dirtyKeys, {tp});
      store.failingKeys.clear();
      await repo.setTutorialCompleted(true);
      expect(store.data[tp], 20);
      expect(repo.dirtyKeys, isEmpty);
    });
  });

  group('sound_muted (C5, FR13.2, AC5.3.2)', () {
    const sm = ProgressRepository.soundMutedKey;

    test('a missing key means sound is on, without a warning', () async {
      final repo = await _loaded(FakeProgressStore());
      expect(repo.soundMuted, isFalse);
      expect(log.lines, isEmpty);
    });

    test('a saved true is read back', () async {
      final repo = await _loaded(FakeProgressStore(initial: {sm: true}));
      expect(repo.soundMuted, isTrue);
    });

    test('a non-bool value means sound is on, with a warning', () async {
      final repo = await _loaded(FakeProgressStore(initial: {sm: 'yes'}));
      expect(repo.soundMuted, isFalse);
      expect(log.where('key $sm is not a bool'), hasLength(1));
    });

    test('setSoundMuted survives a restart', () async {
      final store = FakeProgressStore();
      final repo = await _loaded(store);
      await repo.setSoundMuted(true);
      expect(store.data[sm], true);
      final restarted = await _loaded(FakeProgressStore(initial: store.data));
      expect(restarted.soundMuted, isTrue);
    });

    test('a failed write marks it dirty and the next write retries', () async {
      final store = FakeProgressStore()..failingKeys.add(sm);
      final repo = await _loaded(store);
      await repo.setSoundMuted(true);
      expect(repo.soundMuted, isTrue);
      expect(repo.dirtyKeys, {sm});
      store.failingKeys.clear();
      await repo.setTutorialCompleted(true);
      expect(repo.dirtyKeys, isEmpty);
      expect(store.data[sm], true);
    });

    test('read-only mode keeps the choice in memory only', () async {
      final store = FakeProgressStore()..initAlwaysFails = true;
      final repo = await _loaded(store);
      await repo.setSoundMuted(true);
      expect(repo.soundMuted, isTrue);
      expect(store.attempts, isEmpty);
    });
  });

  group('legacy keys (E3)', () {
    Future<void> settle() => Future<void>.delayed(Duration.zero);

    test('all four legacy keys are removed after load (E3, AC5.2.1)', () async {
      final store = FakeProgressStore(
        initial: {
          'high_score': 1200,
          'high_score_time': 300,
          'theme_index': 2,
          'last_login_date': '2026-11-17',
          key: _progressJson(current: 4),
        },
      );
      await _loaded(store);
      await settle();
      expect(store.removed, [
        'high_score',
        'high_score_time',
        'theme_index',
        'last_login_date',
      ]);
      expect(store.data.containsKey(key), isTrue, reason: 'progress is kept');
    });

    test('nothing is removed when the legacy keys are absent', () async {
      final store = FakeProgressStore();
      await _loaded(store);
      await settle();
      expect(store.removed, isEmpty);
      expect(log.lines, isEmpty);
    });

    test(
      'a failed removal is logged and does not break later writes',
      () async {
        final store = FakeProgressStore(initial: {'high_score': 1})
          ..failingRemovals.add('high_score');
        final repo = await _loaded(store);
        await repo.setTutorialCompleted(true);
        expect(
          log.where('removing legacy key high_score failed'),
          hasLength(1),
        );
        expect(store.data[tut], true);
        expect(repo.dirtyKeys, isEmpty);
      },
    );

    test('read-only mode removes nothing', () async {
      final store = FakeProgressStore(initial: {'high_score': 1})
        ..initAlwaysFails = true;
      await _loaded(store);
      await settle();
      expect(store.removed, isEmpty);
    });
  });

  group('SharedPreferencesProgressStore', () {
    test('writeInt stores an int (total_play_time)', () async {
      SharedPreferences.setMockInitialValues({});
      final store = SharedPreferencesProgressStore();
      await store.init();
      await store.writeInt(ProgressRepository.totalPlayTimeKey, 75);
      expect(store.read(ProgressRepository.totalPlayTimeKey), 75);
    });

    test('remove deletes a key and tolerates a missing one', () async {
      SharedPreferences.setMockInitialValues({'high_score': 5});
      final store = SharedPreferencesProgressStore();
      await store.init();
      await store.remove('high_score');
      expect(store.read('high_score'), isNull);
      await store.remove('never_there');
    });
    test(
      'round-trips string and bool values through SharedPreferences',
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
      },
    );

    test('reading before init throws a StateError', () {
      expect(
        () => SharedPreferencesProgressStore().read(key),
        throwsStateError,
      );
    });

    test(
      'the repository works end to end on top of SharedPreferences',
      () async {
        SharedPreferences.setMockInitialValues({
          key: _progressJson(
            current: 7,
            completed: [1, 2, 3, 4, 5, 6],
            highest: 7,
          ),
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
      },
    );
  });
}
