import 'package:flutter/material.dart';
import '../models/block_model.dart';
import 'draggable_block.dart';

class BlockPalette extends StatelessWidget {
  final List<BlockModel> blocks;
  final Function(BlockModel) onDragStart;
  final ValueChanged<Offset> onDragUpdate;
  final VoidCallback onDragEnd;

  const BlockPalette({
    super.key,
    required this.blocks,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: blocks.map((block) {
          return DraggableBlock(
            block: block,
            onDragStart: () => onDragStart(block),
            onDragUpdate: onDragUpdate,
            onDragEnd: onDragEnd,
          );
        }).toList(),
      ),
    );
  }
}
