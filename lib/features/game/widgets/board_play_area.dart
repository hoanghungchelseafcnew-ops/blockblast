import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../engine/board_geometry.dart';
import '../models/block_model.dart';
import '../models/cell_model.dart';
import 'block_palette.dart';
import 'game_board.dart';

/// Bảng + khay khối + kéo-thả, dùng chung cho màn level và màn endless.
///
/// Chỉ đổi tọa độ chạm thành ô trên lưới (có nâng khối lên trên ngón tay) rồi
/// giao cho callback; không giữ state của ván.
class BoardPlayArea extends StatefulWidget {
  const BoardPlayArea({
    super.key,
    required this.board,
    required this.tray,
    required this.activeBlock,
    required this.onDragStart,
    required this.onPreview,
    required this.onPlace,
    required this.onCancel,
  });

  final List<List<CellModel>> board;
  final List<BlockModel> tray;

  /// Khối đang được kéo (null khi không kéo).
  final BlockModel? activeBlock;
  final ValueChanged<BlockModel> onDragStart;
  final void Function(int row, int col) onPreview;
  final void Function(int row, int col) onPlace;
  final VoidCallback onCancel;

  @override
  State<BoardPlayArea> createState() => _BoardPlayAreaState();
}

class _BoardPlayAreaState extends State<BoardPlayArea> {
  final GlobalKey _boardKey = GlobalKey();
  Offset? _lastDragPosition;

  BoardCellPosition? _cellAt(Offset global, BlockModel block) {
    final box = _boardKey.currentContext?.findRenderObject();
    if (box is! RenderBox) return null;
    return BoardGeometry.cellFor(
      local: box.globalToLocal(global),
      boardWidth: box.size.width,
      block: block,
    );
  }

  void _onDragUpdate(Offset global) {
    final block = widget.activeBlock;
    if (block == null) return;
    _lastDragPosition = global;
    final cell = _cellAt(global, block);
    if (cell == null) return;
    widget.onPreview(cell.row, cell.col);
  }

  void _onDragEnd() {
    final block = widget.activeBlock;
    final drag = _lastDragPosition;
    _lastDragPosition = null;
    final cell = (block == null || drag == null) ? null : _cellAt(drag, block);
    if (cell == null) {
      widget.onCancel();
      return;
    }
    widget.onPlace(cell.row, cell.col);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final trayHeight = BlockPalette.totalHeight + _trayPadding * 2;

        // Bảng là hình vuông, rộng tối đa bằng chiều ngang. Nếu màn hình quá
        // thấp để chứa cả bảng và khay thì bảng nhỏ lại, nên không bao giờ
        // tràn (overflow) dù máy iOS hay Android nào.
        var boardSide = constraints.maxWidth;
        if (availableHeight.isFinite) {
          boardSide = math.min(boardSide, availableHeight - trayHeight);
        }
        boardSide = math.max(boardSide, BoardGeometry.innerPadding * 2);

        final trayBox = availableHeight.isFinite
            ? math.min(trayHeight, availableHeight)
            : trayHeight;

        return Column(
          children: [
            const Spacer(),
            SizedBox(
              width: boardSide,
              child: RepaintBoundary(
                child: Container(
                  key: _boardKey,
                  child: GameBoard(board: widget.board),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              height: trayBox,
              width: constraints.maxWidth,
              // Máy rất thấp: khay co lại thay vì tràn.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: trayHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: _trayPadding),
                    child: RepaintBoundary(
                      child: BlockPalette(
                        blocks: widget.tray,
                        boardCellSize: BoardGeometry.cellSize(boardSide),
                        onDragStart: widget.onDragStart,
                        onDragUpdate: _onDragUpdate,
                        onDragEnd: _onDragEnd,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Đệm dọc phía trên và dưới khay.
  static const double _trayPadding = 4;
}
