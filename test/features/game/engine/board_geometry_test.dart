import 'package:block_blast/features/game/engine/board_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

import 'engine_test_helpers.dart';

void main() {
  group('BoardGeometry', () {
    test('cellSize divides the inner width by the 8 columns', () {
      expect(BoardGeometry.cellSize(396), (396 - 2 * 26) / 8);
    });

    test('a single cell under the first grid cell maps to (0,0)', () {
      const width = 396.0;
      final size = BoardGeometry.cellSize(width);
      final local = Offset(
        BoardGeometry.innerPadding + size / 2,
        BoardGeometry.innerPadding + size / 2,
      );
      final cell =
          BoardGeometry.cellFor(local: local, boardWidth: width, block: single());
      expect(cell, (row: 0, col: 0));
    });

    test('a wide block is centred under the finger', () {
      const width = 396.0;
      final size = BoardGeometry.cellSize(width);
      final local = Offset(
        BoardGeometry.innerPadding + size * 3,
        BoardGeometry.innerPadding + size / 2,
      );
      final cell =
          BoardGeometry.cellFor(local: local, boardWidth: width, block: line(4));
      expect(cell.col, 1);
      expect(cell.row, 0);
    });

    test('positions outside the board are returned unclamped', () {
      final cell = BoardGeometry.cellFor(
        local: const Offset(-100, -100),
        boardWidth: 396,
        block: single(),
      );
      expect(cell.row, lessThan(0));
      expect(cell.col, lessThan(0));
    });
  });
}
