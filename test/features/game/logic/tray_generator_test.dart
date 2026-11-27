import 'dart:math';

import 'package:block_blast/features/game/logic/block_catalog.dart';
import 'package:block_blast/features/game/logic/difficulty_constants.dart';
import 'package:block_blast/features/game/logic/tray_generator.dart';
import 'package:block_blast/features/game/logic/tray_models.dart';
import 'package:block_blast/features/game/logic/tray_solver.dart';
import 'package:block_blast/features/game/models/block_model.dart';
import 'package:block_blast/features/game/models/cell_model.dart';
import 'package:flutter_test/flutter_test.dart';

List<List<CellModel>> _emptyBoard() =>
    List.generate(8, (_) => List.generate(8, (_) => CellModel()));

List<List<CellModel>> _boardFromRows(List<int> rows) {
  final board = _emptyBoard();
  for (var r = 0; r < 8; r++) {
    for (var c = 0; c < 8; c++) {
      board[r][c].filled = (rows[r] & (1 << c)) != 0;
    }
  }
  return board;
}

List<List<CellModel>> _randomBoard(Random random, int fillPercent) {
  final rows = List<int>.filled(8, 0);
  for (var r = 0; r < 8; r++) {
    for (var c = 0; c < 8; c++) {
      if (random.nextInt(100) < fillPercent) rows[r] |= 1 << c;
    }
    if (rows[r] == 255) rows[r] = 127;
  }
  return _boardFromRows(rows);
}

int _empties(List<List<CellModel>> board) =>
    board.expand((row) => row).where((c) => !c.filled).length;

void main() {
  group('TrayGenerator', () {
    test('an empty board gets a strict tray of three blocks', () {
      final result = TrayGenerator(random: Random(1)).prepare(_emptyBoard(), 1);
      expect(result.gameOver, isFalse);
      expect(result.tier, SolvabilityTier.strict);
      expect(result.tray.length, 3);
    });

    test('the returned tray cannot be modified (BR1.1)', () {
      final result = TrayGenerator(random: Random(1)).prepare(_emptyBoard(), 5);
      final extra = BlockModel(
        shape: BlockCatalog.small.first,
        color: BlockCatalog.colors.first,
      );
      expect(() => result.tray.add(extra), throwsUnsupportedError);
      expect(() => result.tray[0] = extra, throwsUnsupportedError);
      expect(() => result.tray.removeAt(0), throwsUnsupportedError);
    });

    test('a completely full board is Game Over with an empty tray (BR1.4)', () {
      final board = _boardFromRows(List<int>.filled(8, 255));
      final result = TrayGenerator(random: Random(2)).prepare(board, 10);
      expect(result.gameOver, isTrue);
      expect(result.tray, isEmpty);
      expect(result.tier, isNull);
    });

    test('a board with no room for a 1x1 is Game Over at every level', () {
      final board = _boardFromRows(List<int>.filled(8, 255));
      for (final level in [1, 18, 36]) {
        expect(
          TrayGenerator(random: Random(level)).prepare(board, level).gameOver,
          isTrue,
        );
      }
    });

    test('a board with three scattered empty cells still gets a tray', () {
      final rows = List<int>.filled(8, 255);
      rows[0] = 255 & ~1;
      rows[3] = 255 & ~(1 << 4);
      rows[6] = 255 & ~(1 << 7);
      final result = TrayGenerator(
        random: Random(3),
      ).prepare(_boardFromRows(rows), 20);
      expect(result.gameOver, isFalse);
      expect(result.tray.length, 3);
    });

    test('a nearly full board still gets a solvable tray', () {
      // Hai ô trống kề nhau trong một hàng và một ô trống tách rời.
      final rows = List<int>.filled(8, 255);
      rows[1] = 255 & ~3;
      rows[5] = 255 & ~(1 << 6);
      final board = _boardFromRows(rows);
      final result = TrayGenerator(random: Random(4)).prepare(board, 30);
      expect(result.gameOver, isFalse);
      expect(result.tray.length, 3);
      expect(
        TraySolver.solve(
          TraySolver.rowsOf(board),
          result.tray,
          strict: false,
          budget: NodeBudget(1000000),
        ),
        SolveOutcome.solvable,
      );
    });

    test('never Game Over while three or more cells are empty (NFR2.1)', () {
      final random = Random(99);
      var checked = 0;
      for (var i = 0; i < 60; i++) {
        final board = _randomBoard(random, 30 + random.nextInt(60));
        if (_empties(board) < 3) continue;
        checked++;
        final result = TrayGenerator(
          random: Random(i),
        ).prepare(board, 1 + random.nextInt(36));
        expect(result.gameOver, isFalse, reason: 'board $i');
        expect(result.tray.length, 3);
      }
      expect(checked, greaterThan(20));
    });

    test('the tier reported is backed by the solver (NFR2.3)', () {
      final random = Random(11);
      for (var i = 0; i < 30; i++) {
        final board = _randomBoard(random, 30 + random.nextInt(45));
        if (_empties(board) < 3) continue;
        final result = TrayGenerator(random: Random(i)).prepare(board, 12);
        final rows = TraySolver.rowsOf(board);
        final tier = result.tier!;
        if (tier == SolvabilityTier.strict) {
          expect(
            TraySolver.solve(
              rows,
              result.tray,
              strict: true,
              budget: NodeBudget(1000000),
            ),
            SolveOutcome.solvable,
          );
        } else {
          expect(
            TraySolver.solve(
              rows,
              result.tray,
              strict: false,
              budget: NodeBudget(1000000),
            ),
            SolveOutcome.solvable,
          );
        }
      }
    });

    test('rescue blocks only appear when some shape can clear a line', () {
      // Bảng trống: không hình nào xóa được dòng nên không có khối cứu.
      var rescued = 0;
      for (var i = 0; i < 100; i++) {
        final r = TrayGenerator(random: Random(i)).prepare(_emptyBoard(), 1);
        rescued += r.tray.where((b) => b.isClearing).length;
      }
      expect(rescued, 0);
    });

    test('rescue blocks do appear when a line can be completed (AC4.2.1)', () {
      final rows = List<int>.filled(8, 0);
      rows[7] = 255 & ~(3 << 3); // thiếu hai ô liền nhau ở hàng cuối
      final board = _boardFromRows(rows);
      var rescued = 0;
      for (var i = 0; i < 100; i++) {
        final r = TrayGenerator(random: Random(i)).prepare(board, 1);
        rescued += r.tray.where((b) => b.isClearing).length;
      }
      // Kỳ vọng khoảng 30% của 300 khối; chỉ cần chắc chắn có xuất hiện.
      expect(rescued, greaterThan(20));
    });

    test('a tray never holds more than two large blocks (BR3.3)', () {
      for (var i = 0; i < 200; i++) {
        final r = TrayGenerator(random: Random(i)).prepare(_emptyBoard(), 36);
        final large = r.tray.where((b) => BlockCatalog.isLarge(b.shape)).length;
        expect(large, lessThanOrEqualTo(DifficultyConstants.maxLargePerTray));
      }
    });

    test('large blocks are more frequent at level 36 than at level 1', () {
      int largeAt(int level) {
        var count = 0;
        for (var i = 0; i < 400; i++) {
          final r = TrayGenerator(
            random: Random(i),
          ).prepare(_emptyBoard(), level);
          count += r.tray.where((b) => BlockCatalog.isLarge(b.shape)).length;
        }
        return count;
      }

      expect(largeAt(36), greaterThan(largeAt(1)));
    });

    test('the same seed, board and level give the same tray (AC4.6.2)', () {
      final board = _randomBoard(Random(8), 45);
      final a = TrayGenerator(random: Random(42)).prepare(board, 15);
      final b = TrayGenerator(random: Random(42)).prepare(board, 15);
      expect(a.tier, b.tier);
      expect(a.tray.length, b.tray.length);
      for (var i = 0; i < a.tray.length; i++) {
        expect(a.tray[i].shape, b.tray[i].shape);
        expect(a.tray[i].color, b.tray[i].color);
        expect(a.tray[i].isIce, b.tray[i].isIce);
        expect(a.tray[i].isBomb, b.tray[i].isBomb);
      }
    });

    test('ice and bomb stay at about 5% each (AC4.6.3)', () {
      var ice = 0;
      var bomb = 0;
      var total = 0;
      for (var i = 0; i < 1000; i++) {
        final r = TrayGenerator(random: Random(i)).prepare(_emptyBoard(), 10);
        for (final b in r.tray) {
          total++;
          if (b.isIce) ice++;
          if (b.isBomb) bomb++;
        }
      }
      expect(ice / total, inInclusiveRange(0.035, 0.065));
      expect(bomb / total, inInclusiveRange(0.035, 0.065));
    });

    test('every block uses a catalog shape and palette color', () {
      final r = TrayGenerator(random: Random(6)).prepare(_emptyBoard(), 20);
      for (final b in r.tray) {
        expect(BlockCatalog.all.any((s) => identical(s, b.shape)), isTrue);
        expect(BlockCatalog.colors, contains(b.color));
      }
    });

    test('preparing a tray stays within the 16 ms target on average', () {
      final boards = [
        for (var i = 0; i < 40; i++) _randomBoard(Random(i), 60 + i % 25),
      ];
      final watch = Stopwatch()..start();
      for (var i = 0; i < boards.length; i++) {
        TrayGenerator(random: Random(i)).prepare(boards[i], 1 + i % 36);
      }
      watch.stop();
      final average = watch.elapsedMicroseconds / boards.length / 1000;
      expect(average, lessThan(16));
    });
  });
}
