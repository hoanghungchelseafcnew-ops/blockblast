import 'package:block_blast/core/constants/game_constants.dart';
import 'package:block_blast/features/game/engine/board_engine.dart';
import 'package:block_blast/features/game/models/block_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'engine_test_helpers.dart';

BoardEngine _engine(List<BlockModel> Function() source) =>
    BoardEngine(blockSource: source, clearDelay: Duration.zero);

void main() {
  group('BoardEngine', () {
    test('starts with an empty board, a full tray and zero score', () {
      final engine = _engine(() => [single(), single(), single()]);
      expect(engine.tray.length, 3);
      expect(engine.score, 0);
      expect(engine.comboStreak, 0);
      expect(engine.board.expand((r) => r).any((c) => c.filled), isFalse);
      expect(engine.board.length, GameConstants.boardSize);
    });

    test('place adds score, removes the block from the tray', () {
      final engine = _engine(() => [single(), line(2), line(3)]);
      final block = engine.tray[1];
      final result = engine.place(block, 0, 0);
      expect(result, isNotNull);
      expect(engine.score, 20);
      expect(engine.tray.contains(block), isFalse);
      expect(engine.tray.length, 2);
    });

    test('place returns null and keeps score when the block does not fit', () {
      final engine = _engine(() => [line(3), single(), single()]);
      final block = engine.tray.first;
      expect(engine.place(block, 0, 6), isNull);
      expect(engine.score, 0);
      expect(engine.tray.length, 3);
    });

    test('a cleared row raises combo and applyClear empties the row', () async {
      final engine = _engine(() => [line(8), single(), single()]);
      final result = engine.place(engine.tray.first, 0, 0)!;
      expect(result.linesCleared, 1);
      expect(engine.comboStreak, 1);
      expect(engine.score, 80 + 100);
      await engine.applyClear();
      expect(engine.board[0].every((c) => !c.filled), isTrue);
      expect(engine.board[0].every((c) => !c.clearing), isTrue);
    });

    test('combo resets after a move that clears nothing', () async {
      final engine = _engine(() => [line(8), single(), single()]);
      engine.place(engine.tray.first, 0, 0);
      expect(engine.comboStreak, 1);
      await engine.applyClear();
      engine.place(engine.tray.first, 5, 5);
      expect(engine.comboStreak, 0);
    });

    test('refillTrayIfEmpty only refills an empty tray', () {
      var calls = 0;
      final engine = _engine(() {
        calls++;
        return [single()];
      });
      expect(engine.refillTrayIfEmpty(), isFalse);
      engine.place(engine.tray.first, 0, 0);
      expect(engine.tray, isEmpty);
      expect(engine.refillTrayIfEmpty(), isTrue);
      expect(engine.tray.length, 1);
      expect(calls, 2);
    });

    test('hasMoves is false when no tray block fits (full board)', () {
      final engine = _engine(() => [single(), single(), single()]);
      for (final row in engine.board) {
        for (final cell in row) {
          cell.filled = true;
        }
      }
      expect(engine.hasMoves, isFalse);
      engine.board[4][4].filled = false;
      expect(engine.hasMoves, isTrue);
    });

    test('hasMoves is false when the only gap is smaller than every block', () {
      final engine = _engine(() => [line(2), line(3), line(2)]);
      for (final row in engine.board) {
        for (final cell in row) {
          cell.filled = true;
        }
      }
      engine.board[1][1].filled = false;
      expect(engine.hasMoves, isFalse);
    });

    test('showPreview marks cells only when the block fits', () {
      final engine = _engine(() => [line(2), single(), single()]);
      final block = engine.tray.first;
      expect(engine.showPreview(block, 0, 0), isTrue);
      expect(engine.board[0][0].preview, isTrue);
      expect(engine.board[0][1].preview, isTrue);
      expect(engine.board[0][2].preview, isFalse);
      expect(engine.showPreview(block, 0, 7), isFalse);
      expect(engine.board[0][0].preview, isFalse);
      engine.showPreview(block, 1, 1);
      engine.clearPreview();
      expect(engine.board.expand((r) => r).any((c) => c.preview), isFalse);
    });

    test('clearCenter empties the 3x3 area in the middle only', () {
      final engine = _engine(() => [single(), single(), single()]);
      for (final row in engine.board) {
        for (final cell in row) {
          cell.filled = true;
        }
      }
      engine.clearCenter();
      for (var r = 3; r <= 5; r++) {
        for (var c = 3; c <= 5; c++) {
          expect(engine.board[r][c].filled, isFalse, reason: '($r,$c)');
        }
      }
      expect(engine.board[2][3].filled, isTrue);
      expect(engine.board[6][5].filled, isTrue);
    });

    test('reset gives a fresh round', () {
      final engine = _engine(() => [single(), single(), single()]);
      engine.place(engine.tray.first, 0, 0);
      engine.reset();
      expect(engine.score, 0);
      expect(engine.tray.length, 3);
      expect(engine.board[0][0].filled, isFalse);
    });

    test(
      'a bomb cell clears its 3x3 neighbourhood when its line clears',
      () async {
        final engine = _engine(() => [single(), single(), single()]);
        final bomb = makeBlock([
          [1],
        ], isBomb: true);
        for (var c = 0; c < 7; c++) {
          engine.board[0][c].filled = true;
        }
        engine.board[1][2].filled = true;
        engine.tray = [bomb];
        final result = engine.place(bomb, 0, 7)!;
        expect(result.linesCleared, 1);
        await engine.applyClear();
        expect(engine.board[0].every((c) => !c.filled), isTrue);
        expect(
          engine.board[1][2].filled,
          isTrue,
          reason: 'bomb at (0,7) only reaches columns 6..7',
        );
      },
    );
  });
}
