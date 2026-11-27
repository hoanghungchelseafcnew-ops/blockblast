import 'dart:convert';

import 'package:block_blast/core/firebase/default_level_config.dart';
import 'package:block_blast/features/endless/controllers/endless_game_controller.dart';
import 'package:block_blast/features/game/engine/board_engine.dart';
import 'package:block_blast/features/game/models/block_model.dart';
import 'package:block_blast/features/game/models/game_snapshot.dart';
import 'package:block_blast/features/journey/controllers/journey_controller.dart';
import 'package:block_blast/features/journey/controllers/level_game_controller.dart';
import 'package:block_blast/features/journey/models/level.dart';
import 'package:block_blast/features/journey/services/level_catalog.dart';
import 'package:block_blast/features/journey/services/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_analytics.dart';
import '../../fakes/fake_progress_store.dart';
import '../../fakes/log_capture.dart';
import 'engine/engine_test_helpers.dart';

List<BlockModel> _fixedTray() => [single(), line(2), line(3)];

GameSnapshot _snapshot({
  GameMode mode = GameMode.level,
  int level = 5,
  int score = 120,
}) {
  final board = List.generate(8, (_) => List<SavedCell?>.filled(8, null));
  board[2][3] = const SavedCell(
    color: 0xFFFF3366,
    isIce: true,
    iceHealth: 2,
    isBomb: false,
  );
  board[7][7] = const SavedCell(
    color: 0xFF33CCFF,
    isIce: false,
    iceHealth: 0,
    isBomb: true,
  );
  return GameSnapshot(
    mode: mode,
    levelIndex: level,
    score: score,
    comboStreak: 2,
    board: board,
    tray: const [
      SavedBlock(
        shape: [
          [1, 1],
          [1, 0],
        ],
        color: 0xFFFFCC00,
        isIce: false,
        iceHealth: 0,
        isBomb: false,
      ),
    ],
  );
}

Map<String, Object> _json() => _snapshot().toJson();

class _Setup {
  _Setup(this.store, this.repo, this.catalog);

  final FakeProgressStore store;
  final ProgressRepository repo;
  final LevelCatalog catalog;

  static Future<_Setup> create({Map<String, Object>? initial}) async {
    final store = FakeProgressStore(initial: initial);
    final repo = ProgressRepository(store);
    await repo.load();
    return _Setup(store, repo, LevelCatalog.from(DefaultLevelConfig.config));
  }

  Level level(int index, int target) {
    final base = catalog.byIndex(index);
    return Level(
      levelIndex: base.levelIndex,
      gemId: base.gemId,
      gemName: base.gemName,
      gemOrder: base.gemOrder,
      subId: base.subId,
      subName: base.subName,
      subOrder: base.subOrder,
      targetScore: target,
      assetPath: base.assetPath,
    );
  }

  LevelGameController levelController(BoardEngine engine) {
    final c = LevelGameController(
      journey: JourneyController(repository: repo, catalog: catalog),
      progress: repo,
      engine: engine,
      analytics: FakeAnalytics(),
      comboTextDuration: const Duration(milliseconds: 50),
    );
    addTearDown(c.dispose);
    return c;
  }

  BoardEngine engine() =>
      BoardEngine(blockSource: _fixedTray, clearDelay: Duration.zero);

  /// Chờ hàng đợi ghi chạy hết.
  Future<void> settle() => repo.flushDirty();

  /// Mở lại app: kho lưu giữ nguyên, repository mới đọc lại từ đầu.
  Future<_Setup> reopen() async {
    final next = ProgressRepository(store);
    await next.load();
    return _Setup(store, next, catalog);
  }
}

Future<void> _place(LevelGameController c, BlockModel block, int r, int col) {
  c.onDragStart(block);
  return c.placeAt(r, col);
}

void main() {
  setUp(() {
    LogCapture().start();
  });

  group('GameSnapshot', () {
    test('survives a JSON round trip', () {
      final text = jsonEncode(_json());
      final parsed = GameSnapshot.tryParse(jsonDecode(text))!;
      expect(parsed.mode, GameMode.level);
      expect(parsed.levelIndex, 5);
      expect(parsed.score, 120);
      expect(parsed.comboStreak, 2);
      expect(parsed.board[2][3]!.isIce, isTrue);
      expect(parsed.board[2][3]!.iceHealth, 2);
      expect(parsed.board[7][7]!.isBomb, isTrue);
      expect(parsed.board[0][0], isNull);
      expect(parsed.tray.single.shape, [
        [1, 1],
        [1, 0],
      ]);
      expect(parsed.tray.single.color, 0xFFFFCC00);
    });

    test('rejects anything that is not a valid current save', () {
      Map<String, Object> mutate(void Function(Map<String, Object>) f) {
        final map = Map<String, Object>.of(_json());
        f(map);
        return map;
      }

      expect(GameSnapshot.tryParse(null), isNull);
      expect(GameSnapshot.tryParse('text'), isNull);
      expect(GameSnapshot.tryParse(mutate((m) => m['v'] = 99)), isNull);
      expect(GameSnapshot.tryParse(mutate((m) => m['mode'] = 'x')), isNull);
      expect(GameSnapshot.tryParse(mutate((m) => m['score'] = -1)), isNull);
      expect(GameSnapshot.tryParse(mutate((m) => m['tray'] = [])), isNull);
      expect(GameSnapshot.tryParse(mutate((m) => m['board'] = [[]])), isNull);
      expect(
        GameSnapshot.tryParse(
          mutate((m) {
            m['tray'] = [
              {
                'shape': [
                  [1, 1],
                  [1],
                ],
                'color': 1,
                'ice': false,
                'iceHealth': 0,
                'bomb': false,
              },
            ];
          }),
        ),
        isNull,
        reason: 'ragged shape',
      );
      expect(
        GameSnapshot.tryParse(
          mutate((m) {
            m['tray'] = [
              {
                'shape': [
                  [0, 0],
                ],
                'color': 1,
                'ice': false,
                'iceHealth': 0,
                'bomb': false,
              },
            ];
          }),
        ),
        isNull,
        reason: 'empty shape',
      );
    });
  });

  group('BoardEngine snapshot and restore', () {
    test('restore rebuilds board, tray, score and combo', () {
      final engine = BoardEngine(
        blockSource: _fixedTray,
        clearDelay: Duration.zero,
      );
      engine.place(engine.tray.first, 4, 4);
      engine.board[1][1]
        ..isIce = true
        ..iceHealth = 2;
      final saved = engine.snapshot(mode: GameMode.level, levelIndex: 3);

      final other = BoardEngine(
        blockSource: _fixedTray,
        clearDelay: Duration.zero,
      );
      other.restore(saved);
      expect(other.score, engine.score);
      expect(other.comboStreak, engine.comboStreak);
      expect(other.tray.length, 2);
      expect(other.board[4][4].filled, isTrue);
      expect(other.board[1][1].isIce, isFalse, reason: 'unfilled cell');
      expect(other.board[0][0].filled, isFalse);
      expect(
        other.tray.map((b) => b.cols).toList(),
        engine.tray.map((b) => b.cols).toList(),
      );
    });

    test('snapshot keeps colour and special flags of filled cells', () {
      final engine = BoardEngine(
        blockSource: _fixedTray,
        clearDelay: Duration.zero,
      );
      final bomb = makeBlock([
        [1],
      ], isBomb: true);
      engine.tray = [bomb];
      engine.place(bomb, 6, 6);
      final saved = engine.snapshot(mode: GameMode.endless);
      final cell = saved.board[6][6]!;
      expect(cell.isBomb, isTrue);
      expect(cell.color, Colors.blue.toARGB32());
      expect(saved.mode, GameMode.endless);
    });
  });

  group('ProgressRepository sessions', () {
    test('saves and clears the level session through the store', () async {
      final s = await _Setup.create();
      await s.repo.saveLevelSession(_snapshot());
      expect(s.store.data[ProgressRepository.levelSessionKey], isA<String>());
      expect(s.repo.levelSession!.score, 120);
      await s.repo.saveLevelSession(null);
      expect(
        s.store.data.containsKey(ProgressRepository.levelSessionKey),
        isFalse,
      );
      expect(s.repo.levelSession, isNull);
    });

    test('reads the session back after a restart', () async {
      final s = await _Setup.create();
      await s.repo.saveLevelSession(_snapshot());
      await s.repo.saveEndlessSession(_snapshot(mode: GameMode.endless));
      final again = await s.reopen();
      expect(again.repo.levelSession!.levelIndex, 5);
      expect(again.repo.endlessSession!.mode, GameMode.endless);
    });

    test('a corrupt or foreign session is dropped, not thrown', () async {
      final s = await _Setup.create(
        initial: {
          ProgressRepository.levelSessionKey: '{not json',
          ProgressRepository.endlessSessionKey: jsonEncode(_json()),
        },
      );
      expect(s.repo.levelSession, isNull);
      expect(
        s.repo.endlessSession,
        isNull,
        reason: 'level save in endless key',
      );
    });

    test('a failed write is kept in cache and marked dirty', () async {
      final s = await _Setup.create();
      s.store.failingKeys.add(ProgressRepository.levelSessionKey);
      await s.repo.saveLevelSession(_snapshot());
      expect(s.repo.levelSession, isNotNull);
      expect(s.repo.dirtyKeys, contains(ProgressRepository.levelSessionKey));
    });
  });

  group('resuming a level', () {
    test('quit then PLAY brings back score, board and tray', () async {
      final s = await _Setup.create();
      final first = s.levelController(s.engine())
        ..start(s.level(3, 1000), resumeSaved: true);
      await _place(first, first.tray.first, 4, 4);
      final scoreBefore = first.score;
      expect(scoreBefore, greaterThan(0));
      first.confirmQuit();
      await s.settle();

      final back = await s.reopen();
      final second = back.levelController(back.engine())
        ..start(back.level(3, 1000), resumeSaved: true);
      expect(second.score, scoreBefore);
      expect(second.board[4][4].filled, isTrue);
      expect(second.tray.length, 2);
      expect(second.status, LevelStatus.playing);
    });

    test(
      'a game with no resume flag starts fresh and drops the save',
      () async {
        final s = await _Setup.create();
        final first = s.levelController(s.engine())
          ..start(s.level(3, 1000), resumeSaved: true);
        await _place(first, first.tray.first, 4, 4);
        await s.settle();
        expect(s.repo.levelSession, isNotNull);

        final second = s.levelController(s.engine())..start(s.level(3, 1000));
        expect(second.score, 0);
        expect(second.board[4][4].filled, isFalse);
        await s.settle();
        expect(s.repo.levelSession, isNull);
      },
    );

    test('a save from another level is ignored and removed', () async {
      final s = await _Setup.create();
      final first = s.levelController(s.engine())
        ..start(s.level(3, 1000), resumeSaved: true);
      await _place(first, first.tray.first, 4, 4);
      await s.settle();

      final second = s.levelController(s.engine())
        ..start(s.level(4, 1000), resumeSaved: true);
      expect(second.score, 0);
      await s.settle();
      expect(s.repo.levelSession, isNull);
    });

    test('winning the level clears the save', () async {
      final s = await _Setup.create();
      final c = s.levelController(s.engine())
        ..start(s.level(2, 20), resumeSaved: true);
      await _place(c, c.tray.first, 0, 0);
      await s.settle();
      expect(s.repo.levelSession, isNotNull);
      await _place(c, c.tray.first, 3, 3);
      await s.settle();
      expect(c.status, LevelStatus.won);
      expect(s.repo.levelSession, isNull);
    });

    test('losing the level clears the save', () async {
      final s = await _Setup.create();
      final engine = BoardEngine(
        blockSource: () => [single(), line(2), line(2)],
        clearDelay: Duration.zero,
      );
      final c = s.levelController(engine)
        ..start(s.level(9, 100000), resumeSaved: true);
      // Mỗi hàng và cột còn đúng hai ô trống không kề nhau.
      for (final row in engine.board) {
        for (final cell in row) {
          cell.filled = true;
        }
      }
      for (var i = 0; i < 8; i++) {
        engine.board[i][i].filled = false;
        engine.board[i][(i + 4) % 8].filled = false;
      }
      await _place(c, c.tray.first, 0, 0);
      await s.settle();
      expect(c.status, LevelStatus.lost);
      expect(s.repo.levelSession, isNull);
    });

    test(
      'a saved score already past a lowered target wins on resume',
      () async {
        final s = await _Setup.create();
        final first = s.levelController(s.engine())
          ..start(s.level(3, 1000), resumeSaved: true);
        await _place(first, first.tray.first, 4, 4);
        await s.settle();

        final second = s.levelController(s.engine())
          ..start(s.level(3, 5), resumeSaved: true);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(second.status, LevelStatus.won);
      },
    );

    test('saveOnPause stores the game and ignores a finished one', () async {
      final s = await _Setup.create();
      final c = s.levelController(s.engine())
        ..start(s.level(3, 1000), resumeSaved: true);
      c.saveOnPause();
      await s.settle();
      expect(s.repo.levelSession, isNotNull);
      expect(s.repo.levelSession!.score, 0);

      c.confirmQuit();
      await s.repo.saveLevelSession(null);
      c.saveOnPause();
      await s.settle();
      expect(s.repo.levelSession, isNull, reason: 'status is quit');
    });

    test('a corrupt save falls back to a fresh game', () async {
      final s = await _Setup.create(
        initial: {ProgressRepository.levelSessionKey: 'garbage'},
      );
      final c = s.levelController(s.engine())
        ..start(s.level(3, 1000), resumeSaved: true);
      expect(c.score, 0);
      expect(c.tray.length, 3);
    });
  });

  group('resuming Endless', () {
    EndlessGameController endless(_Setup s) {
      final c = EndlessGameController(progress: s.repo, engine: s.engine());
      addTearDown(c.dispose);
      return c;
    }

    test('quit then PLAY brings back the board and tray', () async {
      final s = await _Setup.create();
      final first = endless(s)..start(resumeSaved: true);
      first.onDragStart(first.tray.first);
      await first.placeAt(5, 5);
      final score = first.score;
      expect(score, greaterThan(0));
      await first.confirmQuit();
      await s.settle();

      final back = await s.reopen();
      final second = endless(back)..start(resumeSaved: true);
      expect(second.score, score);
      expect(second.board[5][5].filled, isTrue);
      expect(second.tray.length, 2);
    });

    test('start without resume keeps the old behaviour', () async {
      final s = await _Setup.create();
      final first = endless(s)..start(resumeSaved: true);
      first.onDragStart(first.tray.first);
      await first.placeAt(5, 5);
      await first.confirmQuit();
      await s.settle();

      final second = endless(s)..start();
      expect(second.score, s.repo.endlessState.savedScore);
      expect(second.board[5][5].filled, isFalse);
      await s.settle();
      expect(s.repo.endlessSession, isNull);
    });

    test('losing clears the saved game', () async {
      final s = await _Setup.create();
      final engine = BoardEngine(
        blockSource: () => [single(), line(2), line(2)],
        clearDelay: Duration.zero,
      );
      final c = EndlessGameController(progress: s.repo, engine: engine)
        ..start(resumeSaved: true);
      addTearDown(c.dispose);
      for (final row in engine.board) {
        for (final cell in row) {
          cell.filled = true;
        }
      }
      for (var i = 0; i < 8; i++) {
        engine.board[i][i].filled = false;
        engine.board[i][(i + 4) % 8].filled = false;
      }
      c.onDragStart(c.tray.first);
      await c.placeAt(0, 0);
      await s.settle();
      expect(s.repo.endlessSession, isNull);
    });
  });
}
