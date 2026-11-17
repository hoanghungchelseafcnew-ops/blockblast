import '../logic/block_generator.dart';
import '../logic/board_logic.dart';
import '../models/block_model.dart';
import '../models/cell_model.dart';
import 'turn_resolver.dart';
import 'turn_result.dart';

/// Nguồn sinh khay 3 khối. Test thay bằng danh sách cố định.
typedef BlockSource = List<BlockModel> Function();

/// Trạng thái bảng 8×8 và khay khối của một ván (chỉ trong bộ nhớ).
///
/// Không biết gì về level, mốc điểm hay tiến trình: chỉ đặt khối, tính điểm,
/// xóa dòng và kiểm tra hết nước đi (US2.2).
class BoardEngine {
  BoardEngine({
    BlockSource? blockSource,
    this.clearDelay = const Duration(milliseconds: 180),
  }) : _blockSource = blockSource ?? BlockGenerator.generateThree {
    reset();
  }

  final BlockSource _blockSource;

  /// Thời gian animation xóa dòng (BR5.10).
  final Duration clearDelay;

  late List<List<CellModel>> board;
  late List<BlockModel> tray;
  int score = 0;
  int comboStreak = 0;

  /// Bảng trống, khay mới, điểm và combo về 0.
  void reset() {
    board = BoardLogic.createEmptyBoard();
    tray = List<BlockModel>.of(_blockSource());
    score = 0;
    comboStreak = 0;
  }

  bool canPlace(BlockModel block, int row, int col) =>
      BoardLogic.canPlaceBlock(board, block, row, col);

  /// Hiện preview của [block] tại ([row], [col]). Trả true nếu đặt được.
  bool showPreview(BlockModel block, int row, int col) {
    clearPreview();
    if (!canPlace(block, row, col)) return false;
    for (var r = 0; r < block.rows; r++) {
      for (var c = 0; c < block.cols; c++) {
        if (block.shape[r][c] == 1) {
          final cell = board[row + r][col + c];
          cell.preview = true;
          cell.previewColor = block.color.withValues(alpha: 0.5);
        }
      }
    }
    return true;
  }

  void clearPreview() {
    for (final row in board) {
      for (final cell in row) {
        cell.preview = false;
        cell.previewColor = null;
      }
    }
  }

  /// Đặt khối, cộng điểm, cập nhật combo và bỏ khối khỏi khay.
  /// Các dòng đầy được đánh dấu nhưng CHƯA xóa: gọi [applyClear] sau.
  TurnResult? place(BlockModel block, int row, int col) {
    final result = TurnResolver.resolve(
      board: board,
      block: block,
      row: row,
      col: col,
      comboStreak: comboStreak,
    );
    if (result == null) return null;
    tray.remove(block);
    score += result.totalScore;
    comboStreak = result.comboStreak;
    return result;
  }

  /// Chạy animation xóa các dòng đã đánh dấu.
  Future<void> applyClear() =>
      BoardLogic.applyClearAnimated(board, delay: clearDelay);

  /// Sinh khay mới khi khay trống. Trả true nếu đã sinh.
  bool refillTrayIfEmpty() {
    if (tray.isNotEmpty) return false;
    tray = List<BlockModel>.of(_blockSource());
    return true;
  }

  /// Còn ít nhất một khối trong khay đặt được ở đâu đó trên bảng.
  bool get hasMoves => BoardLogic.canPlaceAnyBlock(board, tray);

  /// REVIVE: xóa vùng 3×3 giữa bảng.
  void clearCenter() {
    final size = board.length;
    final mid = size ~/ 2;
    for (var r = mid - 1; r <= mid + 1; r++) {
      for (var c = mid - 1; c <= mid + 1; c++) {
        if (r >= 0 && r < size && c >= 0 && c < size) {
          final cell = board[r][c];
          cell.filled = false;
          cell.isIce = false;
          cell.isBomb = false;
          cell.color = null;
        }
      }
    }
  }
}
