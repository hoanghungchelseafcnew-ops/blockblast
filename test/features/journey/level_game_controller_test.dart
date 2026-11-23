import 'package:block_blast/core/firebase/default_level_config.dart';
import 'package:block_blast/features/game/engine/board_engine.dart';
import 'package:block_blast/features/game/models/block_model.dart';
import 'package:block_blast/features/game/services/game_feedback.dart';
import 'package:block_blast/features/journey/controllers/journey_controller.dart';
import 'package:block_blast/features/journey/controllers/level_game_controller.dart';
import 'package:block_blast/features/journey/models/level.dart';
import 'package:block_blast/features/journey/services/level_catalog.dart';
import 'package:block_blast/features/journey/services/progress_repository.dart';
import 'package:block_blast/features/victory/models/victory_variant.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_analytics.dart';
import '../../fakes/fake_progress_store.dart';
import '../../fakes/log_capture.dart';
import '../game/engine/engine_test_helpers.dart';

class RecordingFeedback extends GameFeedback {
  int placedCount = 0;
  int clearedCount = 0;
  int comboCount = 0;
  int gameOverCount = 0;
  int victoryCount = 0;
  int unlockCount = 0;
  int stopCount = 0;

  @override
  void placed() => placedCount++;

  @override
  void cleared() => clearedCount++;

  @override
  void combo() => comboCount++;

  @override
  void gameOver() => gameOverCount++;

  @override
  void victory() => victoryCount++;

  @override
  void unlock() => unlockCount++;

  @override
  void stopSfx() => stopCount++;
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
    Duration unlockDelay = const Duration(milliseconds: 600),
    Duration? progressWriteDelay,
    List<BlockModel> Function()? source,
    FakeAnalytics? analytics,
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
      analytics: analytics ?? FakeAnalytics(),
      resolveTimeout: resolveTimeout,
      unlockDelay: unlockDelay,
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

  group('difficulty level (US4.4, BR4.2)', () {
    test('start gives the engine the level index as its difficulty', () async {
      final g = await _Game.create(levelIndex: 12);
      expect(g.engine.difficultyLevel, 12);
    });

    test('starting another level updates the difficulty', () async {
      final g = await _Game.create(levelIndex: 3);
      g.controller.start(g.levelWith(30, 1000));
      expect(g.engine.difficultyLevel, 30);
    });
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
      expect(c.clearing, isFalse);
      expect(c.outcome, isNull);
      expect(c.tray.length, 3);
      expect(c.roundId, 'round-1');
      expect(c.bestScore, 0);
      expect(c.level.levelIndex, 1);
    });

    test(
      'BEST starts from the saved high score of the level (AC1.7.1)',
      () async {
        final g = await _Game.create(
          levelIndex: 9,
          target: 100000,
          initial: {ProgressRepository.highScoresKey: '{"9":1300}'},
        );
        final c = g.controller;
        expect(c.bestScore, 1300);
        await g.place(c.tray.first, 0, 0);
        expect(c.bestScore, 1300, reason: 'score 10 is below the best');
      },
    );

    test('BEST follows the score once it beats the saved best', () async {
      final g = await _Game.create(
        target: 100000,
        initial: {ProgressRepository.highScoresKey: '{"1":5}'},
      );
      final c = g.controller;
      await g.place(c.tray.first, 0, 0);
      expect(c.bestScore, 10);
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

    test('level 36 has no CONTINUE: the call does nothing (AC3.3.2)', () async {
      final g = await _Game.create(levelIndex: 36, target: 10);
      final c = g.controller;
      await g.place(c.tray.first, 0, 0);
      expect(c.outcome!.nextLevel, isNull);
      expect(c.victoryVariant, VictoryVariant.journeyComplete);
      expect(g.repo.progress.journeyCompleted, isTrue, reason: 'AC3.3.3');
      c.continueAfterWin();
      expect(c.status, LevelStatus.won);
      expect(c.roundId, 'round-1');
    });

    test('CONTINUE does nothing unless the round is won', () async {
      final g = await _Game.create();
      g.controller.continueAfterWin();
      expect(g.controller.roundId, 'round-1');
    });
  });

  group('victory audio and CONTINUE (FR6.1, FR6.2, AC3.1.3)', () {
    const delay = Duration(milliseconds: 30);
    Future<void> wait() =>
        Future<void>.delayed(const Duration(milliseconds: 60));

    test('a sub-level win plays victory once and no unlock', () async {
      final g = await _Game.create(
        levelIndex: 2,
        target: 10,
        unlockDelay: delay,
      );
      await g.place(g.controller.tray.first, 0, 0);
      expect(g.controller.victoryVariant, VictoryVariant.sub);
      expect(g.feedback.victoryCount, 1);
      await wait();
      expect(g.feedback.unlockCount, 0);
    });

    test('a Bling win plays unlock after the delay (AC3.2.1)', () async {
      final g = await _Game.create(
        levelIndex: 6,
        target: 10,
        unlockDelay: delay,
      );
      await g.place(g.controller.tray.first, 0, 0);
      expect(g.controller.victoryVariant, VictoryVariant.gemUnlock);
      expect(g.feedback.victoryCount, 1);
      expect(g.feedback.unlockCount, 0, reason: 'not before the delay');
      await wait();
      expect(g.feedback.unlockCount, 1);
    });

    test('level 36 also plays unlock after victory', () async {
      final g = await _Game.create(
        levelIndex: 36,
        target: 10,
        unlockDelay: delay,
      );
      await g.place(g.controller.tray.first, 0, 0);
      await wait();
      expect(g.feedback.victoryCount, 1);
      expect(g.feedback.unlockCount, 1);
    });

    test(
      'CONTINUE before the delay cancels unlock and stops the sound',
      () async {
        final g = await _Game.create(
          levelIndex: 6,
          target: 10,
          unlockDelay: delay,
        );
        await g.place(g.controller.tray.first, 0, 0);
        g.controller.continueAfterWin();
        expect(g.feedback.stopCount, 1);
        await wait();
        expect(g.feedback.unlockCount, 0);
        expect(g.controller.level.levelIndex, 7);
      },
    );

    test('CONTINUE twice moves on only once', () async {
      final g = await _Game.create(levelIndex: 2, target: 10);
      await g.place(g.controller.tray.first, 0, 0);
      g.controller.continueAfterWin();
      g.controller.continueAfterWin();
      expect(g.controller.level.levelIndex, 3);
      expect(g.controller.roundId, 'round-2');
      expect(g.feedback.stopCount, 1);
    });

    test('leaving the level 36 victory stops the celebration', () async {
      final g = await _Game.create(
        levelIndex: 36,
        target: 10,
        unlockDelay: delay,
      );
      await g.place(g.controller.tray.first, 0, 0);
      expect(g.controller.requestBack(), isTrue);
      expect(g.feedback.stopCount, 1);
      await wait();
      expect(g.feedback.unlockCount, 0);
    });

    test('disposing before the delay cancels unlock', () async {
      final g = await _Game.create(
        levelIndex: 6,
        target: 10,
        unlockDelay: delay,
      );
      await g.place(g.controller.tray.first, 0, 0);
      g.controller.dispose();
      await wait();
      expect(g.feedback.unlockCount, 0);
    });
  });

  group('running out of moves (WF5, FR2.3, ADR-008)', () {
    // Level 9 = Amethyst · Shaping; Rough Stone của Amethyst là level 7.
    test(
      'no moves below target saves the return to Rough Stone, then lost',
      () async {
        final g = await _Game.create(levelIndex: 9, target: 100000);
        g.fillBoardLeavingIsolatedGaps();
        final c = g.controller;
        await g.place(c.tray.first, 0, 0);
        expect(c.status, LevelStatus.lost);
        expect(g.feedback.gameOverCount, 1);
        expect(c.outcome!.nextLevel!.levelIndex, 7);
        expect(c.returnLevel.levelIndex, 7);
        expect(g.repo.progress.currentLevelIndex, 7);
        expect(g.store.data[ProgressRepository.progressKey], isNotNull);
        expect(g.repo.highScore(9), 10, reason: 'AC1.7.2 on a loss');
      },
    );

    test('the loss goes through resolving before lost', () async {
      final g = await _Game.create(
        levelIndex: 9,
        target: 100000,
        progressWriteDelay: const Duration(milliseconds: 40),
      );
      g.fillBoardLeavingIsolatedGaps();
      final c = g.controller;
      c.onDragStart(c.tray.first);
      final turn = c.placeAt(0, 0);
      await Future<void>.delayed(Duration.zero);
      expect(c.status, LevelStatus.resolving);
      expect(c.requestBack(), isFalse);
      expect(c.confirmQuit(), isFalse, reason: 'no quit while resolving');
      await turn;
      expect(c.status, LevelStatus.lost);
    });

    test(
      'a slow save ends after the timeout with the cached outcome',
      () async {
        final g = await _Game.create(
          levelIndex: 9,
          target: 100000,
          resolveTimeout: const Duration(milliseconds: 30),
          progressWriteDelay: const Duration(milliseconds: 300),
        );
        g.fillBoardLeavingIsolatedGaps();
        await g.place(g.controller.tray.first, 0, 0);
        expect(g.controller.status, LevelStatus.lost);
        expect(g.controller.outcome!.nextLevel!.levelIndex, 7);
        expect(log.where('resolving timed out'), hasLength(1));
        await Future<void>.delayed(const Duration(milliseconds: 350));
      },
    );

    test('a failed save still reaches lost without throwing', () async {
      final g = await _Game.create(levelIndex: 9, target: 100000);
      g.store.failingKeys.add(ProgressRepository.progressKey);
      g.fillBoardLeavingIsolatedGaps();
      await g.place(g.controller.tray.first, 0, 0);
      expect(g.controller.status, LevelStatus.lost);
      expect(g.repo.dirtyKeys, contains(ProgressRepository.progressKey));
    });

    test('a loss is processed once per round', () async {
      final g = await _Game.create(levelIndex: 9, target: 100000);
      g.fillBoardLeavingIsolatedGaps();
      final c = g.controller;
      await g.place(c.tray.first, 0, 0);
      final writes = g.store.attemptsFor(ProgressRepository.progressKey);
      await g.place(c.tray.first, 0, 4);
      expect(g.store.attemptsFor(ProgressRepository.progressKey), writes);
      expect(g.feedback.gameOverCount, 1);
    });

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

    test('PLAY AGAIN starts a new round at the Rough Stone (FR2.3)', () async {
      final g = await _Game.create(levelIndex: 9, target: 100000);
      g.fillBoardLeavingIsolatedGaps();
      final c = g.controller;
      await g.place(c.tray.first, 0, 0);
      c.playAgain();
      expect(c.status, LevelStatus.playing);
      expect(c.roundId, 'round-2');
      expect(c.level.levelIndex, 7);
      expect(c.score, 0);
      expect(c.board.expand((r) => r).any((cell) => cell.filled), isFalse);
    });

    test('losing at a Rough Stone replays the same level', () async {
      final g = await _Game.create(levelIndex: 1, target: 100000);
      g.fillBoardLeavingIsolatedGaps();
      final c = g.controller;
      await g.place(c.tray.first, 0, 0);
      c.playAgain();
      expect(c.level.levelIndex, 1);
    });

    test('PLAY AGAIN is ignored when not lost', () async {
      final g = await _Game.create();
      g.controller.playAgain();
      expect(g.controller.roundId, 'round-1');
    });
  });

  group('back and quit (WF6, FR11.2)', () {
    test(
      'back while playing asks for confirmation and changes nothing',
      () async {
        final g = await _Game.create();
        final c = g.controller;
        expect(c.needsQuitConfirmation, isTrue);
        expect(c.requestBack(), isFalse);
        expect(c.status, LevelStatus.playing);
      },
    );

    test('confirmQuit quits and saves only the unfinished game', () async {
      final g = await _Game.create(levelIndex: 9);
      final c = g.controller;
      c.onDragStart(c.tray.first);
      expect(c.confirmQuit(), isTrue);
      expect(c.status, LevelStatus.quit);
      expect(c.activeBlock, isNull);
      expect(c.needsQuitConfirmation, isFalse);
      await g.repo.flushDirty();
      expect(g.store.attempts, [ProgressRepository.levelSessionKey]);
      expect(g.repo.progress.currentLevelIndex, 1);
      expect(c.requestBack(), isTrue);
    });

    test('input is ignored after quitting', () async {
      final g = await _Game.create();
      final c = g.controller;
      c.confirmQuit();
      c.onDragStart(c.tray.first);
      expect(c.activeBlock, isNull);
      expect(c.confirmQuit(), isFalse);
    });

    test('back is allowed from won and lost', () async {
      final won = await _Game.create(target: 10);
      await won.place(won.controller.tray.first, 0, 0);
      expect(won.controller.requestBack(), isTrue);
      expect(won.controller.confirmQuit(), isFalse);
      expect(won.controller.status, LevelStatus.won);

      final lost = await _Game.create(target: 11);
      lost.fillBoardLeavingIsolatedGaps();
      await lost.place(lost.controller.tray.first, 0, 0);
      expect(lost.controller.requestBack(), isTrue);
      expect(lost.controller.status, LevelStatus.lost);
    });

    test('QUIT during the clear animation stops the turn (BR5.10)', () async {
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
      expect(c.confirmQuit(), isTrue);
      expect(c.status, LevelStatus.quit);
      await turn;
      expect(c.status, LevelStatus.quit);
    });
  });

  group('analytics (FR4.1, FR4.2, AC6.3.1, AC6.4.2)', () {
    Future<void> settle() => Future<void>.delayed(Duration.zero);

    test('start sends level_start once for the level', () async {
      final a = FakeAnalytics();
      await _Game.create(levelIndex: 9, analytics: a);
      await settle();
      expect(a.calls, ['start:9']);
    });

    test('a win sends level_complete with score and target, then progress '
        'properties for the next gem level', () async {
      final a = FakeAnalytics();
      final g = await _Game.create(levelIndex: 2, target: 10, analytics: a);
      await g.place(g.controller.tray.first, 0, 0);
      await settle();
      expect(a.calls, ['start:2', 'complete:2:10/10']);
      expect(a.currentMajorLevel, 'rose_quartz');
      expect(a.highestLevelReached, 3);
    });

    test('a Bling win reports the next gem as current major level', () async {
      final a = FakeAnalytics();
      final g = await _Game.create(levelIndex: 6, target: 10, analytics: a);
      await g.place(g.controller.tray.first, 0, 0);
      await settle();
      expect(a.currentMajorLevel, 'amethyst');
      expect(a.highestLevelReached, 7);
    });

    test('a loss sends level_fail and keeps highest_level_reached', () async {
      final a = FakeAnalytics();
      final g = await _Game.create(
        levelIndex: 9,
        target: 100000,
        analytics: a,
        initial: {
          ProgressRepository.progressKey:
              '{"currentLevelIndex":9,"completedLevels":[1,2,3,4,5,6,7,8],'
              '"unlockedGems":["rose_quartz"],"journeyCompleted":false,'
              '"highestLevelReached":12}',
        },
      );
      g.fillBoardLeavingIsolatedGaps();
      await g.place(g.controller.tray.first, 0, 0);
      await settle();
      expect(a.calls, ['start:9', 'fail:9:10/100000']);
      expect(a.currentMajorLevel, 'amethyst');
      expect(a.highestLevelReached, 12, reason: 'never goes down');
    });

    test('PLAY AGAIN and CONTINUE each send a new level_start', () async {
      final a = FakeAnalytics();
      final won = await _Game.create(levelIndex: 2, target: 10, analytics: a);
      await won.place(won.controller.tray.first, 0, 0);
      won.controller.continueAfterWin();
      await settle();
      expect(a.calls.last, 'start:3');

      final b = FakeAnalytics();
      final lost = await _Game.create(
        levelIndex: 9,
        target: 100000,
        analytics: b,
      );
      lost.fillBoardLeavingIsolatedGaps();
      await lost.place(lost.controller.tray.first, 0, 0);
      lost.controller.playAgain();
      await settle();
      expect(b.calls.last, 'start:7');
    });

    test('QUIT sends no level_fail', () async {
      final a = FakeAnalytics();
      final g = await _Game.create(levelIndex: 4, analytics: a);
      g.controller.confirmQuit();
      await settle();
      expect(a.calls, ['start:4']);
    });

    test(
      'a failing analytics service is logged and never breaks the game',
      () async {
        final g = await _Game.create(
          levelIndex: 2,
          target: 10,
          analytics: _ThrowingAnalytics(),
        );
        await g.place(g.controller.tray.first, 0, 0);
        await settle();
        expect(g.controller.status, LevelStatus.won);
        expect(log.where('analytics level_complete failed'), hasLength(1));
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

/// Bản vi phạm contract C4 (ném lỗi), để kiểm lớp bọc của controller.
class _ThrowingAnalytics extends FakeAnalytics {
  @override
  Future<void> logLevelComplete(Level level, int score, int target) async =>
      throw StateError('broken analytics');
}
