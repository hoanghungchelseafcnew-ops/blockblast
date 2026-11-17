import 'dart:ui';

import '../../../core/constants/game_constants.dart';
import '../models/block_model.dart';

/// Ô góc trên-trái nơi khối sẽ được đặt.
typedef BoardCellPosition = ({int row, int col});

/// Đổi tọa độ chạm (đã ở hệ tọa độ của bảng) thành ô trên lưới.
///
/// Giữ đúng công thức cũ của màn chơi để khối nằm dưới ngón tay như trước.
class BoardGeometry {
  const BoardGeometry._();

  /// Phần đệm bên trong bảng tính từ mép widget đến ô đầu tiên.
  static const double innerPadding = GameConstants.boardPadding + 10.0;

  static double cellSize(double boardWidth) =>
      (boardWidth - innerPadding * 2) / GameConstants.boardSize;

  /// Vị trí bắt đầu (hàng, cột) của [block] khi ngón tay ở [local].
  /// Kết quả có thể nằm ngoài bảng; `BoardEngine.canPlace` kiểm tra biên.
  static BoardCellPosition cellFor({
    required Offset local,
    required double boardWidth,
    required BlockModel block,
  }) {
    final size = cellSize(boardWidth);
    final gridX = local.dx - innerPadding;
    final gridY = local.dy - innerPadding;
    final col = ((gridX - (block.cols * size) / 2) / size).round();
    final row = ((gridY - (block.rows * size) / 2) / size).round();
    return (row: row, col: col);
  }
}
