import '../logic/board_logic.dart';
import '../models/block_model.dart';
import '../models/cell_model.dart';
import 'turn_result.dart';

/// Tính một lượt đặt khối. Đồng bộ, duyệt bảng 8×8 (O(64)), không I/O.
class TurnResolver {
  const TurnResolver._();

  /// Điểm cho mỗi ô của khối đặt xuống.
  static const int pointsPerCell = 10;

  /// Điểm cơ bản cho mỗi dòng hoặc cột đầy (trước khi nhân combo).
  static const int pointsPerLine = 100;

  /// Số ô của [block].
  static int countCells(BlockModel block) {
    var count = 0;
    for (final row in block.shape) {
      for (final cell in row) {
        if (cell == 1) count++;
      }
    }
    return count;
  }

  /// Đặt [block] tại ([row], [col]), đánh dấu các dòng đầy là `clearing` và
  /// trả về điểm của lượt. Trả `null` (không đổi bảng) nếu không đặt được.
  ///
  /// Điểm được tính ngay, trước animation xóa dòng (BR5.1).
  static TurnResult? resolve({
    required List<List<CellModel>> board,
    required BlockModel block,
    required int row,
    required int col,
    required int comboStreak,
  }) {
    if (!BoardLogic.canPlaceBlock(board, block, row, col)) return null;

    final cells = countCells(block);
    BoardLogic.placeBlock(board, block, row, col);
    final lines = BoardLogic.clearCompletedLines(board);

    final newCombo = lines > 0 ? comboStreak + 1 : 0;
    return TurnResult(
      cellsPlaced: cells,
      linesCleared: lines,
      comboStreak: newCombo,
      placementScore: cells * pointsPerCell,
      lineScore: lines * pointsPerLine * newCombo,
    );
  }
}
