import 'package:flutter/painting.dart';

import '../logic/board_logic.dart';
import '../logic/difficulty_constants.dart';
import '../logic/tray_generator.dart';
import '../models/block_model.dart';
import '../models/cell_model.dart';
import '../models/game_snapshot.dart';
import 'turn_resolver.dart';
import 'turn_result.dart';

/// Nguồn sinh khay 3 khối. Test thay bằng danh sách cố định.
typedef BlockSource = List<BlockModel> Function();

/// Trạng thái bảng 8×8 và khay khối của một ván (chỉ trong bộ nhớ).
///
/// Không biết gì về mốc điểm hay tiến trình: chỉ đặt khối, tính điểm, xóa dòng
/// và kiểm tra hết nước đi (US2.2). Controller đặt [difficultyLevel] trước khi
/// bắt đầu ván; khay mới do `TrayGenerator` sinh theo bảng và mức đó, trừ khi
/// test truyền `blockSource`.
class BoardEngine {
  BoardEngine({
    BlockSource? blockSource,
    TrayGenerator? trayGenerator,
    this.difficultyLevel = DifficultyConstants.endlessLevel,
    this.clearDelay = const Duration(milliseconds: 180),
  }) : _blockSource = blockSource,
       _trayGenerator = trayGenerator ?? TrayGenerator() {
    reset();
  }

  final BlockSource? _blockSource;
  final TrayGenerator _trayGenerator;

  /// Độ khó dùng để sinh khay: levelIndex ở Journey, 18 ở Endless (BR4.2).
  int difficultyLevel;

  /// Thời gian animation xóa dòng (BR5.10).
  final Duration clearDelay;

  late List<List<CellModel>> board;
  late List<BlockModel> tray;
  int score = 0;
  int comboStreak = 0;

  /// Khay kế tiếp. Khi không còn khay nào đặt hết được, khay rỗng: `hasMoves`
  /// là false nên controller chuyển sang Game Over (BR1.4).
  List<BlockModel> _nextTray() {
    final source = _blockSource;
    if (source != null) return List<BlockModel>.of(source());
    return List<BlockModel>.of(
      _trayGenerator.prepare(board, difficultyLevel).tray,
    );
  }

  /// Bảng trống, khay mới, combo về 0. Điểm bắt đầu là [startScore]: 0 ở chế
  /// độ level, điểm đã lưu ở chế độ endless (FR9.2).
  void reset({int startScore = 0}) {
    board = BoardLogic.createEmptyBoard();
    tray = _nextTray();
    score = startScore < 0 ? 0 : startScore;
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
    tray = _nextTray();
    return true;
  }

  /// Còn ít nhất một khối trong khay đặt được ở đâu đó trên bảng.
  bool get hasMoves => BoardLogic.canPlaceAnyBlock(board, tray);

  /// Có ô bom nằm trong dòng vừa đầy (đang chờ xóa), tức là sắp nổ.
  bool get hasBombClearing =>
      board.any((row) => row.any((cell) => cell.clearing && cell.isBomb));

  /// Bản lưu trạng thái ổn định của ván (điểm, combo, bảng, khay). Chỉ gọi khi
  /// không còn ô nào đang xóa; hiệu ứng xem trước không được lưu.
  GameSnapshot snapshot({required GameMode mode, int levelIndex = 0}) {
    return GameSnapshot(
      mode: mode,
      levelIndex: levelIndex,
      score: score,
      comboStreak: comboStreak,
      board: [
        for (final row in board)
          [
            for (final cell in row)
              cell.filled
                  ? SavedCell(
                      color: GameSnapshot.colorToInt(
                        cell.color ?? const Color(0xFFFFFFFF),
                      ),
                      isIce: cell.isIce,
                      iceHealth: cell.iceHealth,
                      isBomb: cell.isBomb,
                    )
                  : null,
          ],
      ],
      tray: [
        for (final block in tray)
          SavedBlock(
            shape: [for (final row in block.shape) List<int>.of(row)],
            color: GameSnapshot.colorToInt(block.color),
            isIce: block.isIce,
            iceHealth: block.iceHealth,
            isBomb: block.isBomb,
          ),
      ],
    );
  }

  /// Nạp lại ván từ [saved]: bảng, khay, điểm và combo.
  void restore(GameSnapshot saved) {
    board = [
      for (final row in saved.board)
        [
          for (final cell in row)
            cell == null
                ? CellModel()
                : CellModel(
                    filled: true,
                    color: Color(cell.color),
                    isIce: cell.isIce,
                    iceHealth: cell.iceHealth,
                    isBomb: cell.isBomb,
                  ),
        ],
    ];
    tray = [
      for (final block in saved.tray)
        BlockModel(
          shape: [for (final row in block.shape) List<int>.of(row)],
          color: Color(block.color),
          isIce: block.isIce,
          iceHealth: block.iceHealth,
          isBomb: block.isBomb,
        ),
    ];
    score = saved.score;
    comboStreak = saved.comboStreak;
  }
}
