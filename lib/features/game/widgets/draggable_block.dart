import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../../game/models/block_model.dart';
import '../engine/board_geometry.dart';

/// Khối trong khay, kéo được lên bảng. Giữ kiểu vẽ "neon" của app cũ.
///
/// Khi kéo, khối được vẽ bằng kích thước ô của bảng ([boardCellSize]) và nằm
/// phía trên ngón tay theo [BoardGeometry.feedbackAnchor], nên ngón tay không
/// che khối và preview trên bảng khớp với khối đang thấy.
class DraggableBlock extends StatelessWidget {
  final BlockModel block;
  final ValueChanged<Offset> onDragUpdate;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;

  /// Bước lưới của bảng (`BoardGeometry.cellSize`).
  final double boardCellSize;

  /// Vùng chạm của khối trong khay. Khi có giá trị, cả hình chữ nhật này nhận
  /// chạm (kể cả phần trống quanh khối) và khối được căn giữa trong đó. Vị trí
  /// thả không đổi vì khối kéo neo theo [BoardGeometry.feedbackAnchor].
  final Size? hitSize;

  /// Kích thước một ô của khối khi nằm trong khay.
  static const double trayCellSize = 28;
  static const double trayCellMargin = 1.5;

  const DraggableBlock({
    super.key,
    required this.block,
    required this.onDragUpdate,
    required this.onDragStart,
    required this.onDragEnd,
    required this.boardCellSize,
    this.hitSize,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<BlockModel>(
      data: block,
      hitTestBehavior: HitTestBehavior.opaque,
      dragAnchorStrategy: (_, __, ___) =>
          BoardGeometry.feedbackAnchor(boardCellSize, block),
      onDragStarted: onDragStart,
      onDragUpdate: (details) {
        onDragUpdate(details.globalPosition);
      },
      onDragEnd: (_) => onDragEnd(),
      feedback: Material(
        key: const Key('drag-feedback'),
        color: Colors.transparent,
        child: _buildBlock(
          cellSize: boardCellSize,
          margin: GameConstants.cellSpacing / 2,
          opacity: 0.95,
          isDragging: true,
        ),
      ),
      childWhenDragging: _withHitArea(
        Opacity(opacity: 0.3, child: _buildTrayBlock()),
      ),
      child: _withHitArea(_buildTrayBlock()),
    );
  }

  /// Đặt khối giữa vùng chạm [hitSize] (nếu có) để cả vùng nhận chạm. Khối rộng
  /// hơn vùng này (ví dụ 1×5 nằm ngang) co lại cho vừa thay vì tràn ra ngoài.
  Widget _withHitArea(Widget child) {
    final size = hitSize;
    if (size == null) return child;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Center(
        child: FittedBox(fit: BoxFit.scaleDown, child: child),
      ),
    );
  }

  Widget _buildTrayBlock() => _buildBlock(
    cellSize: trayCellSize + trayCellMargin * 2,
    margin: trayCellMargin,
  );

  /// Mỗi ô chiếm đúng [cellSize] (gồm [margin] hai bên), nên cả khối rộng
  /// `cols × cellSize` và cao `rows × cellSize`.
  Widget _buildBlock({
    required double cellSize,
    required double margin,
    double opacity = 1,
    bool isDragging = false,
  }) {
    final inner = cellSize - margin * 2;
    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: block.shape.map((row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: row.map((cell) {
              if (cell == 0) {
                return SizedBox(width: cellSize, height: cellSize);
              }
              return Container(
                width: inner,
                height: inner,
                margin: EdgeInsets.all(margin),
                decoration: BoxDecoration(
                  color: block.color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  gradient: LinearGradient(
                    colors: [block.color.withValues(alpha: 0.7), block.color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    if (isDragging)
                      BoxShadow(
                        color: block.color.withValues(alpha: 0.6),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      )
                    else
                      BoxShadow(
                        color: block.color.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(1, 1),
                      ),
                  ],
                ),
                child: _buildSpecialOverlay(),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSpecialOverlay() {
    if (block.isIce) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Icon(Icons.ac_unit, color: Colors.white, size: 14),
        ),
      );
    }
    if (block.isBomb) {
      return const Center(
        child: Icon(Icons.brightness_low, color: Colors.black, size: 18),
      );
    }
    return const SizedBox.shrink();
  }
}
