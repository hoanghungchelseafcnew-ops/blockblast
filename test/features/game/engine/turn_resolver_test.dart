import 'package:block_blast/core/constants/game_constants.dart';
import 'package:block_blast/features/game/engine/turn_resolver.dart';
import 'package:block_blast/features/game/logic/board_logic.dart';
import 'package:block_blast/features/game/models/cell_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'engine_test_helpers.dart';

List<List<CellModel>> _boardWithRowFilled(int row, {int except = -1}) {
  final board = BoardLogic.createEmptyBoard();
  for (var c = 0; c < GameConstants.boardSize; c++) {
    if (c != except) board[row][c].filled = true;
  }
  return board;
}

void main() {
  group('TurnResolver', () {
    test('placement scores 10 points per cell (BR5.1)', () {
      final board = BoardLogic.createEmptyBoard();
      final result = TurnResolver.resolve(
        board: board,
        block: line(3),
        row: 0,
        col: 0,
        comboStreak: 0,
      );
      expect(result, isNotNull);
      expect(result!.cellsPlaced, 3);
      expect(result.placementScore, 30);
      expect(result.lineScore, 0);
      expect(result.totalScore, 30);
      expect(result.clearedAnyLine, isFalse);
      expect(board[0][0].filled, isTrue);
      expect(board[0][2].filled, isTrue);
    });

    test('one cleared row adds 100 x combo and raises the combo (BR5.1)', () {
      final board = _boardWithRowFilled(2, except: 7);
      final result = TurnResolver.resolve(
        board: board,
        block: single(),
        row: 2,
        col: 7,
        comboStreak: 0,
      )!;
      expect(result.linesCleared, 1);
      expect(result.comboStreak, 1);
      expect(result.lineScore, 100);
      expect(result.totalScore, 110);
      // Dòng được đánh dấu nhưng chưa xóa.
      expect(board[2].every((c) => c.clearing), isTrue);
      expect(board[2].every((c) => c.filled), isTrue);
    });

    test('combo streak multiplies the line bonus', () {
      final board = _boardWithRowFilled(0, except: 0);
      final result = TurnResolver.resolve(
        board: board,
        block: single(),
        row: 0,
        col: 0,
        comboStreak: 2,
      )!;
      expect(result.comboStreak, 3);
      expect(result.lineScore, 300);
    });

    test('a move without a cleared line resets the combo (BR5.2)', () {
      final board = BoardLogic.createEmptyBoard();
      final result = TurnResolver.resolve(
        board: board,
        block: single(),
        row: 4,
        col: 4,
        comboStreak: 5,
      )!;
      expect(result.comboStreak, 0);
      expect(result.lineScore, 0);
    });

    test('clears a row and a column in the same move', () {
      final board = BoardLogic.createEmptyBoard();
      for (var i = 0; i < GameConstants.boardSize; i++) {
        board[3][i].filled = true;
        board[i][3].filled = true;
      }
      board[3][3].filled = false;
      final result = TurnResolver.resolve(
        board: board,
        block: single(),
        row: 3,
        col: 3,
        comboStreak: 0,
      )!;
      expect(result.linesCleared, 2);
      expect(result.lineScore, 200);
    });

    test(
      'returns null and leaves the board untouched when it does not fit',
      () {
        final board = BoardLogic.createEmptyBoard();
        board[0][1].filled = true;
        final overlap = TurnResolver.resolve(
          board: board,
          block: line(2),
          row: 0,
          col: 0,
          comboStreak: 1,
        );
        final outside = TurnResolver.resolve(
          board: board,
          block: line(3),
          row: 0,
          col: 7,
          comboStreak: 1,
        );
        expect(overlap, isNull);
        expect(outside, isNull);
        expect(board[0][0].filled, isFalse);
      },
    );

    test('countCells counts only the filled cells of an L shape', () {
      final block = makeBlock([
        [1, 0],
        [1, 1],
      ]);
      expect(TurnResolver.countCells(block), 3);
    });
  });
}
