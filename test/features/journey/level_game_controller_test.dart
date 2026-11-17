import 'package:block_blast/core/firebase/default_level_config.dart';
import 'package:block_blast/features/game/engine/board_engine.dart';
import 'package:block_blast/features/game/models/block_model.dart';
import 'package:block_blast/features/game/services/game_feedback.dart';
import 'package:block_blast/features/journey/controllers/journey_controller.dart';
import 'package:block_blast/features/journey/controllers/level_game_controller.dart';
import 'package:block_blast/features/journey/models/level.dart';
import 'package:block_blast/features/journey/services/level_catalog.dart';
import 'package:block_blast/features/journey/services/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_progress_store.dart';
import '../../fakes/log_capture.dart';
import '../game/engine/engine_test_helpers.dart';

class RecordingFeedback extends GameFeedback {
  int placedCount = 0;
  int clearedCount = 0;
  int comboCount = 0;
  int gameOverCount = 0;

  @override
  void placed() => placedCount++;

  @override
  void cleared() => clearedCount++;

  @override
  void combo() => comboCount++;

  @override
  void gameOver() => gameOverCount++;
}

class _Game {
  _Game({
    required this.store,
    required this.repo,
    required this.catalog,
    required this.engine,
    required this.controller,
    required this.feedback,
  });

  final FakeProgressStore store;
  final ProgressRepository repo;
  final LevelCatalog catalog;
  final BoardEngine engine;
  final LevelGameController controller;
  final RecordingFeedback feedback;

  static Future<_Game> create({
    int levelIndex = 1,
    int target = 1000,
    Map<String, Object>? initial,
    Duration clearDelay = Duration.zero,
    Duration resolveTimeout = const Duration(seconds: 3),
    Duration? progressWriteDelay,
    List<BlockModel> Function()? source,
    bool start = true,
  }) async {
    final store = FakeProgressStore(initial: initial);
    if (progressWriteDelay != null) {
      store.writeDelay[ProgressRepository.progressKey] = progressWriteDelay;
    }
    final repo = ProgressRepository(store);
    await repo.load();
    final catalog = LevelCatalog.from(DefaultLevelConfig.config);
    final engine = BoardEngine(
      blockSource: source ?? () => [single(), line(2), line(2)],
      clearDelay: clearDelay,
    );
    final feedback = RecordingFeedback();
    var rounds = 0;
    final controller = LevelGameController(
      journey: JourneyController(repository: repo, catalog: catalog),
      progress: repo,
      engine: engine,
      feedback: feedback,
      resolveTimeout: resolveTimeout,
      comboTextDuration: const Duration(milliseconds: 100),
      roundIdFactory: () => 'round-${++rounds}',
    );
    addTearDown(controller.dispose);
    final game = _Game(
      store: store,
      repo: repo,
      catalog: catalog,
      engine: engine,
      controller: controller,
      feedback: feedback,
    );
    if (start) controller.start(game.levelWith(levelIndex, target));
    return game;
  }

  /// Level thật của catalog nhưng với mốc điểm tùy chỉnh.
  Level levelWith(int index, int target) {
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

  Future<void> place(BlockModel block, int row, int col) async {
    controller.onDragStart(block);
    await controller.placeAt(row, col);
  }

  /// Mỗi hàng và cột còn đúng hai ô trống, không hai ô nào kề nhau theo hàng
  /// hoặc cột. Đặt khối đơn vào (0,0) không xóa dòng nào và không còn chỗ cho
  /// khối dài 2, tức là hết nước đi.
  void fillBoardLeavingIsolatedGaps() {
    for (final row in engine.board) {
      for (final cell in row) {
        cell.filled = true;
      }
    }
    for (var i = 0; i < engine.board.length; i++) {
      engine.board[i][i].filled = false;
      engine.board[i][(i + 4) % engine.board.length].filled = false;
    }
  }

  void fillRowExcept(int row, int col) {
    for (var c = 0; c < engine.board[row].length; c++) {
      if (c != col) engine.board[row][c].filled = true;
    }
  }
}

void main() {
  late LogCapture log;

  setUp(() {
    log = LogCapture()..start();
  });

  group('start (WF2, BR5.5)', () {
    test('creates a fresh playing round with the target frozen', () async {
      final g = await _Game.create(target: 700);
      final c = g.controller;
      expect(c.status, LevelStatus.playing);
      expect(c.targetScore, 700);
      expect(c.score, 0);
      expect(c.progressPercent, 0);
      expect(c.comboStreak, 0);
      expect(c.revived, isFalse);
      expect(c.clearing, isFalse);
      expect(c.outcome, isNull);
      expect(c.tray.length, 3);
      expect(c.roundId, 'round-1');
      expect(c.bestScore, 0);
      expect(c.level.levelIndex, 1);
    });

    test('a target below 1 is raised to 1 and logged', () async {
      final g = await _Game.create(target: 0);
      expect(g.controller.targetScore, 1);
      expect(log.where('target below 1'), hasLength(1));
    });

    test('level is not available before start', () async {
      final g = await _Game.create(start: false);
      expect(g.controller.hasLevel, isFalse);
      expect(() => g.controller.level, throwsStateError);
    });

    test(
      'the tutorial shows until the first valid placement (BR3.4)',
      () async {
        final g = await _Game.create();
        final c = g.controller;
        expect(c.tutorialActive, isTrue);
        // Đặt sai chỗ không tính.
        await g.place(c.tray.first, 0, 7 + 5);
        expect(c.tutorialActive, isTrue);
        await g.place(c.tray.first, 0, 0);
        expect(c.tutorialActive, isFalse);
        await g.repo.flushDirty();
        await Future<void>.delayed(Duration.zero);
        expect(g.store.data[ProgressRepository.tutorialKey], true);
      },
    );

    test('the tutorial stays hidden once completed', () async {
      final g = await _Game.create(
        initial: {ProgressRepository.tutorialKey: true},
      );
      expect(g.controller.tutorialActive, isFalse);
    });
  });

  group('placing blocks (WF3, BR5.1, BR5.2)', () {
    test('placing scores 10 per cell and updates the percent', () async {
      final g = await _Game.create(target: 1000);
      final c = g.controller;
      await g.place(c.tray[1], 2, 2);
      expect(c.score, 20);
      expect(c.progressPercent, 2);
      expect(c.tray.length, 2);
      expect(c.status, LevelStatus.playing);
      expect(g.feedback.placedCount, 1);
    });

    test('an invalid placement changes nothing', () async {
      final g = await _Game.create();
      final c = g.controller;
      final before = c.tray.length;
      await g.place(c.tray[1], 0, 7);
      expect(c.score, 0);
      expect(c.tray.length, before);
      expect(c.activeBlock, isNull);
      expect(g.feedback.placedCount, 0);
    });

    test('preview follows the drag and cancelDrag removes it', () async {
      final g = await _Game.create();
      final c = g.controller;
      c.onDragStart(c.tray[1]);
      expect(c.activeBlock, isNotNull);
      c.updatePreview(1, 1);
      expect(c.board[1][1].preview, isTrue);
      c.updatePreview(0, 7);
      expect(c.board[1][1].preview, isFalse);
      c.updatePreview(2, 2);
      c.cancelDrag();
      expect(c.board.expand((r) => r).any((cell) => cell.preview), isFalse);
      expect(c.activeBlock, isNull);
    });

    test(
      'a cleared line adds the bonus, then animation, then a refilled tray',
      () async {
        final g = await _Game.create(
          target: 100000,
          source: () => [single(), single(), single()],
        );
        final c = g.controller;
        g.fillRowExcept(0, 0);
        await g.place(c.tray.first, 0, 0);
        expect(c.score, 110);
        expect(c.comboStreak, 1);
        expect(g.feedback.clearedCount, 1);
        expect(c.board[0].every((cell) => !cell.filled), isTrue);
        expect(c.clearing, isFalse);
      },
    );

    test(
      'back-to-back clears show the combo text, which then disappears',
      () async {
        final g = await _Game.create(
          target: 100000,
          source: () => [single(), single(), single()],
        );
        final c = g.controller;
        g.fillRowExcept(0, 0);
        g.fillRowExcept(1, 0);
        await g.place(c.tray.first, 0, 0);
        expect(c.comboText, isNull);
        await g.place(c.tray.first, 1, 0);
        expect(c.comboStreak, 2);
        expect(c.comboText, 'COMBO x2');
        expect(g.feedback.comboCount, 1);
        await Future<void>.delayed(const Duration(milliseconds: 200));
        expect(c.comboText, isNull);
      },
    );

    test('a move without a cleared line resets the combo streak', () async {
      final g = await _Game.create(
        target: 100000,
        source: () => [single(), single(), single()],
      );
      final c = g.controller;
      g.fillRowExcept(0, 0);
      await g.place(c.tray.first, 0, 0);
      expect(c.comboStreak, 1);
      await g.place(c.tray.first, 5, 5);
      expect(c.comboStreak, 0);
    });
  });

  group('progress percent (BR5.6)', () {
    test('0, 99 and 100 at the boundaries', () async {
      final g = await _Game.create(target: 1000);
      final c = g.controller;
      expect(c.progressPercent, 0);
      g.engine.score = 990;
      expect(c.progressPercent, 99);
      g.engine.score = 999;
      expect(c.progressPercent, 99, reason: 'capped below 100 until the win');
      g.engine.score = 1000;
      expect(c.progressPercent, 100);
      g.engine.score = 5000;
      expect(c.progressPercent, 100);
    });

    test('rounds down: 95 of 105 is 90%', () async {
      final g = await _Game.create(target: 105);
      g.engine.score = 95;
      expect(g.controller.progressPercent, 90);
    });

    test('target = 1 wins on the first placement', () async {
      final g = await _Game.create(target: 1);
      expect(g.controller.progressPercent, 0);
      await g.place(g.controller.tray.first, 0, 0);
      expect(g.controller.status, LevelStatus.won);
      expect(g.controller.progressPercent, 100);
    });
  });

  group('winning (WF4, BR5.3, BR4.1)', () {
    test(
      'reaching the target wins, saves progress and moves to the next level',
      () async {
        final g = await _Game.create(levelIndex: 1, target: 10);
        final c = g.controller;
        await g.place(c.tray.first, 0, 0);
        expect(c.status, LevelStatus.won);
        expect(c.outcome!.nextLevel!.levelIndex, 2);
        expect(c.outcome!.highestLevelReached, 2);
        expect(g.repo.progress.currentLevelIndex, 2);
        expect(g.repo.progress.completedLevels, {1});
        expect(g.store.data[ProgressRepository.progressKey], isNotNull);
        expect(c.progressPercent, 100);
      },
    );

    test(
      'winning takes priority over running out of moves in the same turn',
      () async {
        final g = await _Game.create(target: 10);
        g.fillBoardLeavingIsolatedGaps();
        await g.place(g.controller.tray.first, 0, 0);
        expect(g.controller.status, LevelStatus.won);
        expect(g.feedback.gameOverCount, 0);
      },
    );

    test(
      'winning with a cleared line waits for the animation then wins',
      () async {
        final g = await _Game.create(
          target: 10,
          clearDelay: const Duration(milliseconds: 40),
        );
        final c = g.controller;
        g.fillRowExcept(0, 0);
        c.onDragStart(c.tray.first);
        final turn = c.placeAt(0, 0);
        expect(c.status, LevelStatus.resolving);
        expect(c.clearing, isTrue);
        await turn;
        expect(c.status, LevelStatus.won);
        expect(c.clearing, isFalse);
      },
    );

    test('input and back are ignored while resolving (BR5.4)', () async {
      final g = await _Game.create(
        target: 10,
        progressWriteDelay: const Duration(milliseconds: 60),
      );
      final c = g.controller;
      c.onDragStart(c.tray.first);
      final turn = c.placeAt(0, 0);
      expect(c.status, LevelStatus.resolving);
      c.onDragStart(c.tray.first);
      expect(c.activeBlock, isNull);
      c.updatePreview(3, 3);
      expect(c.board[3][3].preview, isFalse);
      expect(c.requestBack(), isFalse);
      expect(c.status, LevelStatus.resolving);
      await turn;
      expect(c.status, LevelStatus.won);
    });

    test(
      'resolving ends after the timeout using the cached outcome (BR5.9)',
      () async {
        final g = await _Game.create(
          target: 10,
          resolveTimeout: const Duration(milliseconds: 30),
          progressWriteDelay: const Duration(milliseconds: 300),
        );
        final c = g.controller;
        await g.place(c.tray.first, 0, 0);
        expect(c.status, LevelStatus.won);
        expect(c.outcome!.nextLevel!.levelIndex, 2);
        expect(
          g.repo.progress.currentLevelIndex,
          2,
          reason: 'cache is updated',
        );
        expect(log.where('resolving timed out'), hasLength(1));
        // Cho lần ghi chậm hoàn tất để test không để lại việc dở dang.
        await Future<void>.delayed(const Duration(milliseconds: 350));
        expect(g.store.data[ProgressRepository.progressKey], isNotNull);
      },
    );

    test(
      'a win is processed once: later input is ignored and nothing is saved twice',
      () async {
        final g = await _Game.create(target: 10);
        final c = g.controller;
        await g.place(c.tray.first, 0, 0);
        expect(c.status, LevelStatus.won);
        final writes = g.store.attemptsFor(ProgressRepository.progressKey);
        await g.place(c.tray.first, 4, 4);
        expect(c.score, 10);
        expect(c.status, LevelStatus.won);
        expect(g.store.attemptsFor(ProgressRepository.progressKey), writes);
        expect(g.repo.progress.completedLevels.length, 1);
      },
    );

    test('a failed save still reaches won and does not throw', () async {
      final g = await _Game.create(target: 10);
      g.store.failingKeys.add(ProgressRepository.progressKey);
      await g.place(g.controller.tray.first, 0, 0);
      expect(g.controller.status, LevelStatus.won);
      expect(g.controller.outcome!.nextLevel!.levelIndex, 2);
      expect(g.repo.dirtyKeys, {ProgressRepository.progressKey});
    });

    test('CONTINUE starts a new round on the next level', () async {
      final g = await _Game.create(target: 10);
      final c = g.controller;
      await g.place(c.tray.first, 0, 0);
      c.continueAfterWin();
      expect(c.status, LevelStatus.playing);
      expect(c.level.levelIndex, 2);
      expect(c.targetScore, 800);
      expect(c.score, 0);
      expect(c.roundId, 'round-2');
    });

    test('CONTINUE on level 36 replays level 36 (BR4.2)', () async {
      final g = await _Game.create(levelIndex: 36, target: 10);
      final c = g.controller;
      await g.place(c.tray.first, 0, 0);
      expect(c.outcome!.nextLevel, isNull);
      c.continueAfterWin();
      expect(c.level.levelIndex, 36);
      expect(c.status, LevelStatus.playing);
    });

    test('CONTINUE does nothing unless the round is won', () async {
      final g = await _Game.create();
      g.controller.continueAfterWin();
      expect(g.controller.roundId, 'round-1');
    });
  });

  group('running out of moves (WF5, BR5.7)', () {
    test(
      'no moves and below target is lost without touching progress',
      () async {
        final g = await _Game.create(target: 11);
        g.fillBoardLeavingIsolatedGaps();
        await g.place(g.controller.tray.first, 0, 0);
        expect(g.controller.status, LevelStatus.lost);
        expect(g.controller.canRevive, isTrue);
        expect(g.feedback.gameOverCount, 1);
        // The first placement legitimately saves `tutorial_completed`; a loss
        // must never write the progress key.
        expect(
          g.store.attempts,
          isNot(contains('progress')),
          reason: 'U1 never saves progress on a loss',
        );
        expect(g.repo.progress.currentLevelIndex, 1);
      },
    );

    test('input is ignored once lost (BR5.4)', () async {
      final g = await _Game.create(target: 11);
      g.fillBoardLeavingIsolatedGaps();
      final c = g.controller;
      await g.place(c.tray.first, 0, 0);
      final score = c.score;
      c.onDragStart(c.tray.first);
      expect(c.activeBlock, isNull);
      await c.placeAt(0, 5);
      expect(c.score, score);
    });

    test('REVIVE clears the centre once and resumes play', () async {
      final g = await _Game.create(target: 11);
      g.fillBoardLeavingIsolatedGaps();
      final c = g.controller;
      await g.place(c.tray.first, 0, 0);
      expect(c.status, LevelStatus.lost);
      expect(c.board[3][4].filled, isTrue);
      c.revive();
      expect(c.status, LevelStatus.playing);
      expect(c.revived, isTrue);
      expect(c.canRevive, isFalse);
      expect(c.board[3][4].filled, isFalse);
      expect(c.board[2][3].filled, isTrue, reason: 'outside the centre 3x3');
      c.revive();
      expect(c.status, LevelStatus.playing);
    });

    test(
      'REVIVE that frees no room for the tray goes straight back to lost',
      () async {
        // Tray: a single (used to lose) plus two 1x4 lines that cannot fit in
        // the 3x3 centre that REVIVE clears.
        final g = await _Game.create(
          target: 100000,
          source: () => [single(), line(4), line(4)],
        );
        g.fillBoardLeavingIsolatedGaps();
        final c = g.controller;
        await g.place(c.tray.first, 0, 0);
        expect(c.status, LevelStatus.lost);
        expect(g.feedback.gameOverCount, 1);
        c.revive();
        expect(c.revived, isTrue);
        expect(c.status, LevelStatus.lost, reason: 'no 1x4 fits after REVIVE');
        expect(c.canRevive, isFalse);
        expect(g.feedback.gameOverCount, 2);
        expect(g.store.attempts, isNot(contains('progress')));
      },
    );

    test('REVIVE is ignored when the round is not lost', () async {
      final g = await _Game.create();
      g.controller.revive();
      expect(g.controller.revived, isFalse);
    });

    test('PLAY AGAIN opens a new round on the same level', () async {
      final g = await _Game.create(target: 11);
      g.fillBoardLeavingIsolatedGaps();
      final c = g.controller;
      await g.place(c.tray.first, 0, 0);
      c.playAgain();
      expect(c.status, LevelStatus.playing);
      expect(c.roundId, 'round-2');
      expect(c.level.levelIndex, 1);
      expect(c.score, 0);
      expect(c.revived, isFalse);
      expect(c.board.expand((r) => r).any((cell) => cell.filled), isFalse);
    });

    test('PLAY AGAIN is ignored when not lost', () async {
      final g = await _Game.create();
      g.controller.playAgain();
      expect(g.controller.roundId, 'round-1');
    });
  });

  group('back and quit (WF6, BR5.8)', () {
    test('back while playing quits without changing progress', () async {
      final g = await _Game.create();
      final c = g.controller;
      c.onDragStart(c.tray.first);
      expect(c.requestBack(), isTrue);
      expect(c.status, LevelStatus.quit);
      expect(c.activeBlock, isNull);
      expect(g.store.attempts, isEmpty);
      expect(g.repo.progress.currentLevelIndex, 1);
    });

    test('input is ignored after quitting', () async {
      final g = await _Game.create();
      final c = g.controller;
      c.requestBack();
      c.onDragStart(c.tray.first);
      expect(c.activeBlock, isNull);
    });

    test('back is allowed from won, lost and quit', () async {
      final won = await _Game.create(target: 10);
      await won.place(won.controller.tray.first, 0, 0);
      expect(won.controller.requestBack(), isTrue);
      expect(won.controller.status, LevelStatus.won);

      final lost = await _Game.create(target: 11);
      lost.fillBoardLeavingIsolatedGaps();
      await lost.place(lost.controller.tray.first, 0, 0);
      expect(lost.controller.requestBack(), isTrue);
      expect(lost.controller.status, LevelStatus.lost);

      final quit = await _Game.create();
      quit.controller.requestBack();
      expect(quit.controller.requestBack(), isTrue);
    });

    test(
      'back during the clear animation quits and the turn stops (BR5.10)',
      () async {
        final g = await _Game.create(
          target: 100000,
          clearDelay: const Duration(milliseconds: 40),
        );
        final c = g.controller;
        g.fillRowExcept(0, 0);
        c.onDragStart(c.tray.first);
        final turn = c.placeAt(0, 0);
        expect(c.clearing, isTrue);
        c.onDragStart(c.tray[0]);
        expect(c.activeBlock, isNull, reason: 'no new drag while clearing');
        expect(c.requestBack(), isTrue);
        expect(c.status, LevelStatus.quit);
        await turn;
        expect(c.status, LevelStatus.quit);
      },
    );
  });

  group('lifecycle', () {
    test('disposing during an animation does not throw', () async {
      final g = await _Game.create(
        target: 100000,
        clearDelay: const Duration(milliseconds: 30),
      );
      final c = g.controller;
      g.fillRowExcept(0, 0);
      c.onDragStart(c.tray.first);
      final turn = c.placeAt(0, 0);
      c.dispose();
      await turn;
    });

    test(
      'starting a new round while a stale turn is finishing is safe',
      () async {
        final g = await _Game.create(
          target: 100000,
          clearDelay: const Duration(milliseconds: 30),
        );
        final c = g.controller;
        g.fillRowExcept(0, 0);
        c.onDragStart(c.tray.first);
        final turn = c.placeAt(0, 0);
        c.start(g.levelWith(2, 800));
        await turn;
        expect(c.level.levelIndex, 2);
        expect(c.score, 0);
        expect(c.status, LevelStatus.playing);
      },
    );
  });
}
