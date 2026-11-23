import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';

/// Một ô trên bảng. Giữ kiểu vẽ "neon" của app cũ; màu ô theo khối, không
/// theo đá quý (design-system-mapping [Q5]).
class BoardCell extends StatelessWidget {
  final bool filled;
  final bool preview;
  final Color? previewColor;
  final Color? cellColor;
  final bool isIce;
  final bool isBomb;

  const BoardCell({
    super.key,
    required this.filled,
    required this.preview,
    this.previewColor,
    this.cellColor,
    this.isIce = false,
    this.isBomb = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.cellEmpty;
    if (filled) {
      color = cellColor ?? AppColors.cellFilled;
    } else if (preview && previewColor != null) {
      color = previewColor!;
    }

    final decoration = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: filled
            ? Colors.white.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.05),
        width: 1,
      ),
      gradient: filled
          ? LinearGradient(
              colors: [color.withValues(alpha: 0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      boxShadow: [
        if (preview && previewColor != null)
          BoxShadow(
            color: previewColor!.withValues(alpha: 0.6),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        if (filled)
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(2, 2),
          ),
        if (filled)
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            blurRadius: 0,
            offset: const Offset(-1, -1),
          ),
      ],
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      decoration: decoration,
      child: Stack(
        children: [
          if (filled && cellColor != null)
            Center(child: _buildSpecialOverlay()),
        ],
      ),
    );
  }

  Widget _buildSpecialOverlay() {
    if (isIce) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Icon(Icons.ac_unit, color: Colors.white, size: 16),
        ),
      );
    }
    if (isBomb) {
      return const Center(
        child: Icon(Icons.brightness_low, color: Colors.black, size: 20),
      );
    }
    return const SizedBox.shrink();
  }
}
