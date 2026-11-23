import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../logic/block_catalog.dart';
import '../models/block_model.dart';
import 'draggable_block.dart';

/// Khay 3 khối dưới bảng.
///
/// Mỗi khối nằm trong một ô (slot) cố định rộng 1/3 khay và cao bằng khối cao
/// nhất có thể có. Cả ô nhận chạm, nên khối nhỏ như 1×1 vẫn dễ bấm. Khi một
/// khối rời khay, các khối còn lại giữ nguyên ô của mình.
class BlockPalette extends StatefulWidget {
  final List<BlockModel> blocks;
  final Function(BlockModel) onDragStart;
  final ValueChanged<Offset> onDragUpdate;
  final VoidCallback onDragEnd;

  /// Bước lưới của bảng, để khối đang kéo có đúng kích thước ô trên bảng.
  final double boardCellSize;

  const BlockPalette({
    super.key,
    required this.blocks,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.boardCellSize,
  });

  /// Số ô tối thiểu của khay.
  static const int minSlots = 3;

  /// Số hàng của hình cao nhất trong danh mục (hiện là 5).
  static final int _maxBlockRows = BlockCatalog.all
      .map((shape) => shape.length)
      .reduce((a, b) => a > b ? a : b);

  static final double _trayHeight =
      _maxBlockRows *
      (DraggableBlock.trayCellSize + DraggableBlock.trayCellMargin * 2);

  static const double _verticalPadding = 8;

  /// Chiều cao tổng của khay gồm đệm dọc, để màn chơi dành sẵn chỗ.
  static final double totalHeight = _trayHeight + _verticalPadding * 2;

  @override
  State<BlockPalette> createState() => _BlockPaletteState();
}

class _BlockPaletteState extends State<BlockPalette> {
  List<BlockModel?> _slots = const [];

  @override
  void initState() {
    super.initState();
    _syncSlots();
  }

  @override
  void didUpdateWidget(BlockPalette oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSlots();
  }

  /// Giữ khối còn lại ở đúng ô cũ; khối mới vào ô trống đầu tiên.
  void _syncSlots() {
    final count = math.max(BlockPalette.minSlots, widget.blocks.length);
    final remaining = List<BlockModel>.of(widget.blocks);
    final next = List<BlockModel?>.filled(count, null);
    for (var i = 0; i < math.min(_slots.length, count); i++) {
      final block = _slots[i];
      if (block != null && remaining.remove(block)) next[i] = block;
    }
    var slot = 0;
    for (final block in remaining) {
      while (next[slot] != null) {
        slot++;
      }
      next[slot] = block;
    }
    _slots = next;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: BlockPalette._verticalPadding,
      ),
      // Chiều cao cố định theo khối cao nhất có thể có, để khay không co giãn
      // khi khối rời khỏi khay và bảng phía trên không bị dịch chuyển.
      child: SizedBox(
        height: BlockPalette._trayHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final slotSize = Size(
              constraints.maxWidth / _slots.length,
              BlockPalette._trayHeight,
            );
            return Row(
              children: [
                for (final block in _slots)
                  SizedBox(
                    width: slotSize.width,
                    height: slotSize.height,
                    child: block == null
                        ? null
                        : DraggableBlock(
                            key: ObjectKey(block),
                            block: block,
                            boardCellSize: widget.boardCellSize,
                            hitSize: slotSize,
                            onDragStart: () => widget.onDragStart(block),
                            onDragUpdate: widget.onDragUpdate,
                            onDragEnd: widget.onDragEnd,
                          ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
