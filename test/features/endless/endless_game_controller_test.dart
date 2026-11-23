import 'package:block_blast/features/endless/controllers/endless_game_controller.dart';
import 'package:block_blast/features/endless/models/endless_state.dart';
import 'package:block_blast/features/game/engine/board_engine.dart';
import 'package:block_blast/features/game/logic/difficulty_constants.dart';
import 'package:block_blast/features/game/models/block_model.dart';
import 'package:block_blast/features/game/services/game_feedback.dart';
import 'package:block_blast/features/journey/services/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_progress_store.dart';
import '../../fakes/log_capture.dart';
import '../game/engine/engine_test_helpers.dart';

class _Feedback extends GameFeedback {
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

  @override
  void victory() {}

  @override
  void unlock() {}

  @override
  void stopSfx() {}
}

class _Game {
  _Game(this.store, this.repo, this.engine, this.controller, this.feedback);

  final FakeProgressStore store;
  final ProgressRepository repo;
  final BoardEngine engine;
  final EndlessGameController controller;
  final _Feedback feedback;

  static Future<_Game> create({
    Map<String, Object>? initial,
    List<BlockModel> Function()? source,
    bool start = true,
  }) async {
    final store = FakeProgressStore(initial: initial);
    final repo = ProgressRepository(store);
    await repo.load();
    final engine = BoardEngine(
      blockSource: source ?? () => [single(), line(2), line(2)],
      clearDelay: Duration.zero,
    );
    final feedback = _Feedback();
    final controller = EndlessGameController(
      progress: repo,
      engine: engine,
      feedback: feedback,
    );
    addTearDown(controller.dispose);
    if (start) controller.start();
    return _Game(store, repo, engine, controller, feedback);
  }

  Future<void> place(BlockModel block, int row, int col) async {
    controller.onDragStart(block);
    await controller.placeAt(row, col);
  }

  /// Mỗi hàng và cột còn đúng hai ô trống không kề nhau: đặt khối đơn vào
  /// (0,0) không xóa dòng nào và không còn chỗ cho khối dài 2.
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

  void leaveOnlyTheFirstCellOfRowZeroFree() {
    for (final row in engine.board) {
      for (final cell in row) {
        cell.filled = false;
      }
    }
    for (var c = 1; c < engine.board[0].length; c++) {
      engine.board[0][c].filled = true;
    }
  }
}

const _saved = ProgressRepository.endlessSavedKey;
const _high = ProgressRepository.endlessHighKey;

void main() {
  late LogCapture log;

  setUp(() {
    log = LogCapture()..start();
  });

  group('difficulty level (US4.5)', () {
    test('Endless uses the fixed mid-level difficulty 18', () async {
      final g = await _Game.create();
      expect(g.engine.difficultyLevel, DifficultyConstants.endlessLevel);
      expect(g.engine.difficultyLevel, 18);
    });

    test('a restart keeps the Endless difficulty', () async {
      final g = await _Game.create();
      g.engine.difficultyLevel = 5;
      g.controller.start();
      expect(g.engine.difficultyLevel, 18);
    });
  });

  group('start (ER1, ER2)', () {
    test('a fresh install starts at 0 on an empty board', () async {
      final g = await _Game.create();
      final c = g.controller;
      expect(c.status, EndlessStatus.playing);
      expect(c.score, 0);
      expect(c.bestScore, 0);
      expect(c.tray.length, 3);
      expect(c.clearing, isFalse);
      expect(c.activeBlock, isNull);
      expect(c.board.every((r) => r.every((cell) => !cell.filled)), isTrue);
      expect(c.needsQuitConfirmation, isTrue);
    });

    test('continues from the saved score on an empty board', () async {
      final g = await _Game.create(initial: {_saved: 1200, _high: 3000});
      final c = g.controller;
      expect(c.score, 1200);
      expect(c.bestScore, 3000);
      expect(c.board.every((r) => r.every((cell) => !cell.filled)), isTrue);
    });
  });

  group('placing blocks (ER3)', () {
    test('placing a block scores and plays feedback', () async {
      final g = await _Game.create();
      final c = g.controller;
      await g.place(c.tray.first, 0, 0);
      expect(c.score, 10);
      expect(c.tray.length, 2);
      expect(g.feedback.placedCount, 1);
      expect(c.activeBlock, isNull);
    });

    test('BEST follows the score once it beats the saved best', () async {
      final g = await _Game.create(initial: {_saved: 95, _high: 100});
      final c = g.controller;
      expect(c.bestScore, 100);
      await g.place(c.tray.first, 0, 0);
      expect(c.score, 105);
      expect(c.bestScore, 105);
    });

    test('clearing a line runs the clear animation and plays sounds', () async {
      final g = await _Game.create(
        source: () => [single(), single(), single()],
      );
      final c = g.controller;
      g.leaveOnlyTheFirstCellOfRowZeroFree();
      await g.place(c.tray.first, 0, 0);
      expect(c.clearing, isFalse);
      expect(g.feedback.clearedCount, 1);
      expect(c.score, greaterThan(10));
      expect(c.status, EndlessStatus.playing);
    });

    test('an invalid drop keeps the block in the tray', () async {
      final g = await _Game.create();
      final c = g.controller;
      final block = c.tray.first;
      await g.place(block, 0, 0);
      final second = c.tray.first;
      await g.place(second, 0, 0);
      expect(c.tray.length, 2);
      expect(c.tray, contains(second));
    });

    test('preview shows and cancelDrag clears it', () async {
      final g = await _Game.create();
      final c = g.controller;
      c.onDragStart(c.tray.first);
      expect(c.activeBlock, isNotNull);
      c.updatePreview(2, 2);
      expect(c.board[2][2].preview, isTrue);
      c.cancelDrag();
      expect(c.board[2][2].preview, isFalse);
      expect(c.activeBlock, isNull);
    });

    test('drop without a drag does nothing', () async {
      final g = await _Game.create();
      await g.controller.placeAt(0, 0);
      expect(g.controller.score, 0);
    });

    test('updatePreview without a drag does nothing', () async {
      final g = await _Game.create();
      g.controller.updatePreview(0, 0);
      expect(g.controller.board[0][0].preview, isFalse);
    });

    test('refills the tray when it becomes empty', () async {
      final g = await _Game.create(source: () => [single()]);
      final c = g.controller;
      await g.place(c.tray.first, 0, 0);
      expect(c.tray.length, 1);
      expect(c.status, EndlessStatus.playing);
    });
  });

  group('quit and pause (ER4, ER5, ER7)', () {
    test('QUIT saves the current score and best', () async {
      final g = await _Game.create(initial: {_saved: 1100, _high: 5000});
      final c = g.controller;
      await g.place(c.tray.first, 0, 0);
      expect(await c.confirmQuit(), isTrue);
      expect(c.status, EndlessStatus.quit);
      expect(
        g.repo.endlessState,
        const EndlessState(savedScore: 1110, highScore: 5000),
      );
      expect(g.store.data[_saved], 1110);
      expect(c.requestBack(), isTrue);
    });

    test('QUIT with score 0 saves 0', () async {
      final g = await _Game.create(initial: {_saved: 0, _high: 40});
      expect(await g.controller.confirmQuit(), isTrue);
      expect(
        g.repo.endlessState,
        const EndlessState(savedScore: 0, highScore: 40),
      );
    });

    test('QUIT raises the best when the score beats it', () async {
      final g = await _Game.create(initial: {_saved: 1200, _high: 500});
      await g.controller.confirmQuit();
      expect(g.repo.endlessState.highScore, 1200);
    });

    test('confirmQuit is ignored when not playing', () async {
      final g = await _Game.create();
      await g.controller.confirmQuit();
      expect(await g.controller.confirmQuit(), isFalse);
    });

    test('saveOnPause saves and keeps playing', () async {
      final g = await _Game.create(initial: {_saved: 200, _high: 200});
      final c = g.controller;
      await g.place(c.tray.first, 0, 0);
      await c.saveOnPause();
      expect(c.status, EndlessStatus.playing);
      expect(g.repo.endlessState.savedScore, 210);
      expect(g.repo.endlessState.highScore, 210);
    });

    test('saveOnPause is ignored after the round ended', () async {
      final g = await _Game.create(initial: {_saved: 200, _high: 900});
      await g.controller.confirmQuit();
      await g.controller.saveOnPause();
      expect(g.repo.endlessState.savedScore, 200);
    });

    test('a save failure still reaches quit and is logged', () async {
      final g = await _Game.create(initial: {_saved: 50});
      g.store.failingKeys.add(_saved);
      expect(await g.controller.confirmQuit(), isTrue);
      expect(g.controller.status, EndlessStatus.quit);
      expect(log.lines, isNotEmpty);
    });

    test('back is refused while playing and while saving', () async {
      final g = await _Game.create();
      final c = g.controller;
      expect(c.requestBack(), isFalse);
      g.store.writeDelay[_saved] = const Duration(milliseconds: 50);
      final pending = c.confirmQuit();
      expect(c.status, EndlessStatus.saving);
      expect(c.requestBack(), isFalse);
      expect(c.needsQuitConfirmation, isFalse);
      await pending;
      expect(c.requestBack(), isTrue);
    });
  });

  group('losing (ER6, ER7)', () {
    test('losing resets the saved score to 0 and keeps the best', () async {
      final g = await _Game.create(
        initial: {_saved: 800, _high: 700},
        source: () => [single(), line(2), line(2)],
      );
      final c = g.controller;
      g.fillBoardLeavingIsolatedGaps();
      await g.place(c.tray.first, 0, 0);
      expect(c.status, EndlessStatus.lost);
      expect(g.feedback.gameOverCount, 1);
      expect(
        g.repo.endlessState,
        const EndlessState(savedScore: 0, highScore: 810),
      );
      expect(c.requestBack(), isTrue);
    });

    test('a loss never lowers the high score', () async {
      final g = await _Game.create(initial: {_saved: 0, _high: 9000});
      final c = g.controller;
      g.fillBoardLeavingIsolatedGaps();
      await g.place(c.tray.first, 0, 0);
      expect(c.status, EndlessStatus.lost);
      expect(g.repo.endlessState.highScore, 9000);
      expect(c.bestScore, 9000);
    });

    test('a failed save on loss still ends the round', () async {
      final g = await _Game.create();
      g.store.failingKeys.addAll([_saved, _high]);
      g.fillBoardLeavingIsolatedGaps();
      await g.place(g.controller.tray.first, 0, 0);
      expect(g.controller.status, EndlessStatus.lost);
    });

    test('PLAY AGAIN starts from 0 on an empty board', () async {
      final g = await _Game.create(initial: {_saved: 800, _high: 700});
      final c = g.controller;
      g.fillBoardLeavingIsolatedGaps();
      await g.place(c.tray.first, 0, 0);
      c.playAgain();
      expect(c.status, EndlessStatus.playing);
      expect(c.score, 0);
      expect(c.bestScore, 810);
      expect(c.board.every((r) => r.every((cell) => !cell.filled)), isTrue);
    });

    test('playAgain is ignored unless the round was lost', () async {
      final g = await _Game.create(initial: {_saved: 300});
      g.controller.playAgain();
      expect(g.controller.score, 300);
    });

    test('input is ignored after the round ended', () async {
      final g = await _Game.create();
      final c = g.controller;
      g.fillBoardLeavingIsolatedGaps();
      await g.place(c.tray.first, 0, 0);
      final score = c.score;
      c.onDragStart(c.tray.first);
      expect(c.activeBlock, isNull);
      await c.placeAt(1, 1);
      expect(c.score, score);
    });
  });

  group('lifecycle', () {
    test('quitting during the clear animation ends in quit', () async {
      final g = await _Game.create(
        source: () => [single(), single(), single()],
      );
      final c = g.controller;
      g.leaveOnlyTheFirstCellOfRowZeroFree();
      c.onDragStart(c.tray.first);
      final placing = c.placeAt(0, 0);
      await c.confirmQuit();
      await placing;
      expect(c.status, EndlessStatus.quit);
    });

    test('start during an animation makes the old placement stale', () async {
      final g = await _Game.create(
        source: () => [single(), single(), single()],
      );
      final c = g.controller;
      g.leaveOnlyTheFirstCellOfRowZeroFree();
      c.onDragStart(c.tray.first);
      final placing = c.placeAt(0, 0);
      c.start();
      await placing;
      expect(c.status, EndlessStatus.playing);
    });

    test('dispose is idempotent and stops notifications', () async {
      final g = await _Game.create();
      final c = g.controller;
      var notified = 0;
      c.addListener(() => notified++);
      c.dispose();
      c.dispose();
      expect(notified, 0);
    });

    test('no analytics is reachable (ER10)', () async {
      final g = await _Game.create();
      await g.place(g.controller.tray.first, 0, 0);
      await g.controller.confirmQuit();
      expect(log.where('error'), isEmpty);
    });
  });
}
