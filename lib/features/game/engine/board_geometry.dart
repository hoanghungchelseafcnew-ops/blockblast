import 'dart:ui';

import '../../../core/constants/game_constants.dart';
import '../models/block_model.dart';

/// Ô góc trên-trái nơi khối sẽ được đặt.
typedef BoardCellPosition = ({int row, int col});

/// Đổi tọa độ chạm thành ô trên lưới, với khối được nâng lên phía trên ngón
/// tay (yêu cầu của người dùng, 2026-11-18).
///
/// Khối đang kéo được vẽ bằng kích thước ô của bảng. [feedbackAnchor] đặt khối
/// cách ngón tay [liftCells] ô theo chiều dọc và căn giữa theo chiều ngang;
/// [cellFor] tính ô từ đúng tâm đó, nên preview luôn nằm dưới khối người chơi
/// nhìn thấy chứ không nằm dưới ngón tay.
class BoardGeometry {
  const BoardGeometry._();

  /// Phần đệm bên trong bảng tính từ mép widget đến ô đầu tiên.
  static const double innerPadding = GameConstants.boardPadding + 10.0;

  /// Khoảng hở giữa đáy khối và ngón tay, tính bằng số ô. Chỉnh ở đây nếu
  /// thử trên máy thật thấy cao hoặc thấp quá.
  static const double liftCells = 1.5;

  /// Bước lưới (ô cộng khoảng cách) của bảng rộng [boardWidth].
  static double cellSize(double boardWidth) =>
      (boardWidth - innerPadding * 2) / GameConstants.boardSize;

  /// Khoảng nâng tính bằng pixel.
  static double liftOf(double cellSize) => liftCells * cellSize;

  /// Điểm của ngón tay bên trong widget khối đang kéo (kích thước
  /// `cols × cellSize` và `rows × cellSize`): giữa cạnh ngang, thấp hơn đáy
  /// khối một khoảng nâng.
  static Offset feedbackAnchor(double cellSize, BlockModel block) {
    return Offset(
      block.cols * cellSize / 2,
      block.rows * cellSize + liftOf(cellSize),
    );
  }

  /// Tâm của khối đang kéo khi ngón tay ở [pointer] (cùng hệ tọa độ).
  static Offset liftedCenter(
    Offset pointer,
    double cellSize,
    BlockModel block,
  ) {
    return Offset(
      pointer.dx,
      pointer.dy - liftOf(cellSize) - block.rows * cellSize / 2,
    );
  }

  /// Vị trí bắt đầu (hàng, cột) của [block] khi ngón tay ở [local] (hệ tọa
  /// độ của bảng). Kết quả có thể nằm ngoài bảng; `BoardEngine.canPlace` kiểm
  /// tra biên.
  static BoardCellPosition cellFor({
    required Offset local,
    required double boardWidth,
    required BlockModel block,
  }) {
    final size = cellSize(boardWidth);
    final center = liftedCenter(local, size, block);
    final gridX = center.dx - innerPadding;
    final gridY = center.dy - innerPadding;
    final col = ((gridX - (block.cols * size) / 2) / size).round();
    final row = ((gridY - (block.rows * size) / 2) / size).round();
    return (row: row, col: col);
  }
}
