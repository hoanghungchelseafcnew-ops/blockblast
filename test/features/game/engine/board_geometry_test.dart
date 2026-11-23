import 'package:block_blast/features/game/engine/board_geometry.dart';
import 'package:block_blast/features/game/models/block_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'engine_test_helpers.dart';

const _width = 396.0;

BlockModel _square(int n) =>
    makeBlock([for (var r = 0; r < n; r++) List<int>.filled(n, 1)]);

/// Ngón tay cần ở đâu (hệ tọa độ bảng) để góc trên-trái của khối nằm đúng ô
/// ([row], [col]), suy ra từ cách vẽ khối đang kéo (`feedbackAnchor`).
Offset _pointerFor(int row, int col, BlockModel block) {
  final size = BoardGeometry.cellSize(_width);
  final anchor = BoardGeometry.feedbackAnchor(size, block);
  final topLeft = Offset(
    BoardGeometry.innerPadding + col * size,
    BoardGeometry.innerPadding + row * size,
  );
  return topLeft + anchor;
}

void main() {
  group('BoardGeometry basics', () {
    test('cellSize divides the inner width by the 8 columns', () {
      expect(BoardGeometry.cellSize(396), (396 - 2 * 26) / 8);
    });

    test('positions outside the board are returned unclamped', () {
      final cell = BoardGeometry.cellFor(
        local: const Offset(-100, -100),
        boardWidth: _width,
        block: single(),
      );
      expect(cell.row, lessThan(0));
      expect(cell.col, lessThan(0));
    });
  });

  group('lifted drag (user request 2026-11-18)', () {
    test('the dragged block sits 1.5 cells above the finger, centred', () {
      final size = BoardGeometry.cellSize(_width);
      final block = _square(3);
      final anchor = BoardGeometry.feedbackAnchor(size, block);
      expect(anchor.dx, 3 * size / 2, reason: 'horizontally centred');
      expect(
        anchor.dy - 3 * size,
        closeTo(1.5 * size, 1e-9),
        reason: 'gap between the block bottom and the finger',
      );
      expect(BoardGeometry.liftCells, 1.5);
    });

    test('the lifted centre matches the drawn block for the same pointer', () {
      final size = BoardGeometry.cellSize(_width);
      for (final block in [single(), _square(3), line(5)]) {
        const pointer = Offset(200, 300);
        final anchor = BoardGeometry.feedbackAnchor(size, block);
        final drawnTopLeft = pointer - anchor;
        final drawnCentre =
            drawnTopLeft + Offset(block.cols * size / 2, block.rows * size / 2);
        final centre = BoardGeometry.liftedCenter(pointer, size, block);
        expect(centre.dx, closeTo(drawnCentre.dx, 1e-9));
        expect(centre.dy, closeTo(drawnCentre.dy, 1e-9));
      }
    });

    for (final entry in <String, BlockModel>{
      '1x1': single(),
      '3x3': _square(3),
      '1x5': line(5),
    }.entries) {
      test(
        '${entry.key}: the preview cell is the cell under the drawn block',
        () {
          final block = entry.value;
          for (final target in [(0, 0), (2, 1), (5, 3)]) {
            final row = target.$1;
            final col = target.$2;
            if (row + block.rows > 8 || col + block.cols > 8) continue;
            final cell = BoardGeometry.cellFor(
              local: _pointerFor(row, col, block),
              boardWidth: _width,
              block: block,
            );
            expect(cell, (row: row, col: col), reason: '${entry.key} $target');
          }
        },
      );
    }

    test('small finger jitter inside a cell keeps the same cell', () {
      final block = _square(3);
      final base = _pointerFor(2, 2, block);
      final size = BoardGeometry.cellSize(_width);
      for (final d in [-0.4, 0.0, 0.4]) {
        final cell = BoardGeometry.cellFor(
          local: base + Offset(d * size, d * size),
          boardWidth: _width,
          block: block,
        );
        expect(cell, (row: 2, col: 2), reason: 'offset $d');
      }
    });

    test('the bottom row is reachable with the finger below the board', () {
      final block = single();
      final pointer = _pointerFor(7, 4, block);
      expect(
        pointer.dy,
        greaterThan(_width - BoardGeometry.innerPadding),
        reason: 'finger is under the board, not on it',
      );
      final cell = BoardGeometry.cellFor(
        local: pointer,
        boardWidth: _width,
        block: block,
      );
      expect(cell, (row: 7, col: 4));
    });

    test('a finger on the top row places nothing on the board', () {
      final size = BoardGeometry.cellSize(_width);
      final cell = BoardGeometry.cellFor(
        local: Offset(
          BoardGeometry.innerPadding + size / 2,
          BoardGeometry.innerPadding + size / 2,
        ),
        boardWidth: _width,
        block: single(),
      );
      expect(cell.row, lessThan(0), reason: 'the block is drawn above it');
    });
  });
}
