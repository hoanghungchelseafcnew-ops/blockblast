import 'dart:math';

import 'package:block_blast/features/game/logic/block_catalog.dart';
import 'package:block_blast/features/game/logic/tray_solver.dart';
import 'package:block_blast/features/game/models/block_model.dart';
import 'package:block_blast/features/game/models/cell_model.dart';
import 'package:flutter_test/flutter_test.dart';

BlockModel _block(List<List<int>> shape) =>
    BlockModel(shape: shape, color: BlockCatalog.colors.first);

BlockModel _single() => _block(BlockCatalog.small.first);
BlockModel _line(int n) => _block([List<int>.filled(n, 1)]);

List<int> _empty() => List<int>.filled(8, 0);

SolveOutcome _solve(
  List<int> rows,
  List<BlockModel> blocks, {
  required bool strict,
  int budget = 100000,
}) =>
    TraySolver.solve(rows, blocks, strict: strict, budget: NodeBudget(budget));

/// Bộ giải vét cạn độc lập, viết trên lưới bool, dùng để đối chiếu.
bool _referenceSolvable(List<List<bool>> grid, List<BlockModel> blocks) {
  if (blocks.isEmpty) return true;
  final block = blocks.first;
  final rest = blocks.sublist(1);
  for (var r = 0; r + block.rows <= 8; r++) {
    for (var c = 0; c + block.cols <= 8; c++) {
      var fits = true;
      for (var i = 0; i < block.rows && fits; i++) {
        for (var j = 0; j < block.cols; j++) {
          if (block.shape[i][j] == 1 && grid[r + i][c + j]) {
            fits = false;
            break;
          }
        }
      }
      if (!fits) continue;
      final next = [for (final row in grid) List<bool>.of(row)];
      for (var i = 0; i < block.rows; i++) {
        for (var j = 0; j < block.cols; j++) {
          if (block.shape[i][j] == 1) next[r + i][c + j] = true;
        }
      }
      final fullRows = [
        for (var i = 0; i < 8; i++)
          if (next[i].every((v) => v)) i,
      ];
      final fullCols = [
        for (var j = 0; j < 8; j++)
          if (List.generate(8, (i) => next[i][j]).every((v) => v)) j,
      ];
      for (final i in fullRows) {
        for (var j = 0; j < 8; j++) {
          next[i][j] = false;
        }
      }
      for (final j in fullCols) {
        for (var i = 0; i < 8; i++) {
          next[i][j] = false;
        }
      }
      if (_referenceSolvable(next, rest)) return true;
    }
  }
  return false;
}

bool _referenceStrict(List<List<bool>> grid, List<BlockModel> blocks) {
  const orders = [
    [0, 1, 2],
    [0, 2, 1],
    [1, 0, 2],
    [1, 2, 0],
    [2, 0, 1],
    [2, 1, 0],
  ];
  return orders.every(
    (o) => _referenceSolvable(grid, [for (final i in o) blocks[i]]),
  );
}

bool _referenceRelaxed(List<List<bool>> grid, List<BlockModel> blocks) {
  const orders = [
    [0, 1, 2],
    [0, 2, 1],
    [1, 0, 2],
    [1, 2, 0],
    [2, 0, 1],
    [2, 1, 0],
  ];
  return orders.any(
    (o) => _referenceSolvable(grid, [for (final i in o) blocks[i]]),
  );
}

List<List<bool>> _gridOf(List<int> rows) => [
  for (final row in rows) [for (var c = 0; c < 8; c++) (row & (1 << c)) != 0],
];

List<int> _randomRows(Random random, int fillPercent) {
  final rows = _empty();
  for (var r = 0; r < 8; r++) {
    for (var c = 0; c < 8; c++) {
      if (random.nextInt(100) < fillPercent) rows[r] |= 1 << c;
    }
    // Không để hàng đầy sẵn: bảng thật luôn đã xóa hàng đầy.
    if (rows[r] == 255) rows[r] = 127;
  }
  return rows;
}

void main() {
  group('TraySolver', () {
    test('an empty board solves any tray in both modes', () {
      final tray = [_line(5), _block(BlockCatalog.large.first), _single()];
      expect(_solve(_empty(), tray, strict: true), SolveOutcome.solvable);
      expect(_solve(_empty(), tray, strict: false), SolveOutcome.solvable);
    });

    test('a block that fits nowhere makes the tray unsolvable', () {
      // Mỗi hàng chỉ có một ô trống, các ô trống nằm chéo nhau: không có hai ô
      // trống liền kề nên khối 1x2 không đặt được ở đâu.
      final rows = _empty();
      for (var r = 0; r < 8; r++) {
        rows[r] = 0xFF & ~(1 << r);
      }
      final tray = [_line(2), _line(2), _line(2)];
      expect(_solve(rows, tray, strict: false), SolveOutcome.unsolvable);
      expect(_solve(rows, tray, strict: true), SolveOutcome.unsolvable);
    });

    test('a line cleared in between frees room for a later block', () {
      // Hàng 0 đầy trừ cột 0; các hàng 1..7 trống ở cột 0..7 đều có chỗ.
      // Đặt khối 1x1 vào (0,0) xóa hàng 0, rồi còn chỗ cho khối 1x8.
      final rows = _empty();
      rows[0] = 0xFE;
      // Làm các hàng 1..7 đầy một phần để khối 1x8 chỉ vừa ở hàng 0 sau khi xóa.
      for (var r = 1; r < 8; r++) {
        rows[r] = 0x01;
      }
      final tray = [_line(8), _single(), _single()];
      expect(_solve(rows, tray, strict: false), SolveOutcome.solvable);
    });

    test('strict and relaxed agree with the exhaustive reference', () {
      // Hàng 0 thiếu cột 0; hàng r (1..7) thiếu đúng cột r. Kết quả của hai chế
      // độ được đối chiếu với bộ giải vét cạn độc lập.
      final rows = _empty();
      rows[0] = 0xFE;
      for (var r = 1; r < 8; r++) {
        rows[r] = 0xFF & ~(1 << r);
      }
      final tray = [_line(8), _single(), _single()];
      final grid = _gridOf(rows);
      expect(
        _solve(rows, tray, strict: false) == SolveOutcome.solvable,
        _referenceRelaxed(grid, tray),
      );
      expect(
        _solve(rows, tray, strict: true) == SolveOutcome.solvable,
        _referenceStrict(grid, tray),
      );
    });

    test('matches an independent exhaustive solver on random boards', () {
      final random = Random(7);
      final shapes = BlockCatalog.all;
      for (var i = 0; i < 40; i++) {
        final rows = _randomRows(random, 40 + random.nextInt(40));
        final tray = [
          for (var k = 0; k < 3; k++)
            _block(shapes[random.nextInt(shapes.length)]),
        ];
        final grid = _gridOf(rows);
        expect(
          _solve(rows, tray, strict: false) == SolveOutcome.solvable,
          _referenceRelaxed(grid, tray),
          reason: 'relaxed mismatch at board $i',
        );
        expect(
          _solve(rows, tray, strict: true) == SolveOutcome.solvable,
          _referenceStrict(grid, tray),
          reason: 'strict mismatch at board $i',
        );
      }
    });

    test('a tiny budget returns unknown, never a false unsolvable', () {
      final tray = [_line(5), _line(5), _line(5)];
      final out = _solve(_empty(), tray, strict: true, budget: 2);
      expect(out, SolveOutcome.unknown);
    });

    test('the same input gives the same outcome and node usage', () {
      final rows = _randomRows(Random(3), 50);
      final tray = [_line(3), _single(), _block(BlockCatalog.small[3])];
      final a = NodeBudget(5000);
      final b = NodeBudget(5000);
      final ra = TraySolver.solve(rows, tray, strict: true, budget: a);
      final rb = TraySolver.solve(rows, tray, strict: true, budget: b);
      expect(ra, rb);
      expect(a.remaining, b.remaining);
    });

    test('rowsOf and filledCount read the board', () {
      final board = List.generate(
        8,
        (_) => List.generate(8, (_) => CellModel()),
      );
      board[0][0].filled = true;
      board[0][3].filled = true;
      board[7][7].filled = true;
      final rows = TraySolver.rowsOf(board);
      expect(rows[0], 0x09);
      expect(rows[7], 0x80);
      expect(TraySolver.filledCount(rows), 3);
    });

    test('canClearLine detects a block that completes a row', () {
      final rows = _empty();
      rows[0] = 0xFE;
      expect(TraySolver.canClearLine(rows, BlockCatalog.small.first), isTrue);
      expect(
        TraySolver.canClearLine(_empty(), BlockCatalog.small.first),
        isFalse,
      );
    });
  });
}
