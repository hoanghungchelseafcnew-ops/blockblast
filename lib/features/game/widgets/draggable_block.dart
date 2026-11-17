import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../game/models/block_model.dart';
import '../../../core/theme/theme_manager.dart';

class DraggableBlock extends StatelessWidget {
  final BlockModel block;
  final ValueChanged<Offset> onDragUpdate;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;

  const DraggableBlock({
    super.key,
    required this.block,
    required this.onDragUpdate,
    required this.onDragStart,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<BlockModel>(
      data: block,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: onDragStart,
      onDragUpdate: (details) {
        onDragUpdate(details.globalPosition);
      },
      onDragEnd: (_) => onDragEnd(),
      feedback: Transform.scale(
        scale: 1.15,
        child: Material(
          color: Colors.transparent,
          child: _buildBlock(context, opacity: 0.95, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildBlock(context)),
      child: _buildBlock(context),
    );
  }

  Widget _buildBlock(BuildContext context, {double opacity = 1, bool isDragging = false}) {
    final theme = context.watch<ThemeManager>().currentTheme;

    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: block.shape.map((row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: row.map((cell) {
              if (cell == 0) return const SizedBox(width: 28, height: 28);
              
              BoxDecoration decoration;
              
              switch (theme) {
                case AppThemeType.wood:
                  decoration = BoxDecoration(
                    color: block.color,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.brown.withValues(alpha: 0.8), width: 2),
                    boxShadow: [
                      if (isDragging) BoxShadow(color: Colors.black45, blurRadius: 10, offset: const Offset(4, 4))
                      else BoxShadow(color: Colors.black45, blurRadius: 2, offset: const Offset(1, 1))
                    ],
                  );
                  break;
                case AppThemeType.jewel:
                  decoration = BoxDecoration(
                    color: block.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                    gradient: RadialGradient(
                      colors: [Colors.white.withValues(alpha: 0.6), block.color],
                      center: const Alignment(-0.3, -0.3),
                      radius: 0.8,
                    ),
                    boxShadow: [
                      if (isDragging) BoxShadow(color: block.color.withValues(alpha: 0.8), blurRadius: 15, spreadRadius: 2)
                      else BoxShadow(color: block.color.withValues(alpha: 0.6), blurRadius: 8)
                    ],
                  );
                  break;
                case AppThemeType.neon:
                  decoration = BoxDecoration(
                    color: block.color,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                    gradient: LinearGradient(
                      colors: [block.color.withValues(alpha: 0.7), block.color],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      if (isDragging) BoxShadow(color: block.color.withValues(alpha: 0.6), blurRadius: 12, spreadRadius: 2, offset: const Offset(0, 4))
                      else BoxShadow(color: block.color.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(1, 1)),
                    ],
                  );
                  break;
              }

              return Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.all(1.5),
                decoration: decoration,
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
