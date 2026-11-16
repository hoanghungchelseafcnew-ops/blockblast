import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/theme_manager.dart';

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
    final themeManager = context.watch<ThemeManager>();
    final theme = themeManager.currentTheme;

    Color color = const Color(0x1AFFFFFF); // Default translucent
    if (theme == AppThemeType.wood) color = const Color(0x224A3B2C);
    if (theme == AppThemeType.jewel) color = const Color(0x11FFFFFF);

    if (filled) {
      color = cellColor ?? AppColors.cellFilled;
    } else if (preview && previewColor != null) {
      color = previewColor!;
    }

    BoxDecoration decoration;

    switch (theme) {
      case AppThemeType.wood:
        decoration = BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.brown.withOpacity(filled ? 0.8 : 0.2), width: 2),
          boxShadow: filled ? [BoxShadow(color: Colors.black45, blurRadius: 2, offset: const Offset(1, 1))] : [],
        );
        break;
      case AppThemeType.jewel:
        decoration = BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12), // Rounder for jewel
          border: Border.all(color: Colors.white.withOpacity(filled ? 0.5 : 0.1), width: 1),
          gradient: filled
              ? RadialGradient(colors: [Colors.white.withOpacity(0.4), color], center: const Alignment(-0.3, -0.3), radius: 0.8)
              : null,
          boxShadow: filled ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 15)] : [],
        );
        break;
      case AppThemeType.neon:
      default:
        decoration = BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: filled ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.05), width: 1),
          gradient: filled
              ? LinearGradient(colors: [color.withOpacity(0.8), color], begin: Alignment.topLeft, end: Alignment.bottomRight)
              : null,
          boxShadow: [
            if (preview && previewColor != null) BoxShadow(color: previewColor!.withOpacity(0.6), blurRadius: 10, spreadRadius: 1),
            if (filled) BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(2, 2)),
            if (filled) BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 0, offset: const Offset(-1, -1)),
          ],
        );
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      decoration: decoration,
      child: Stack(
        children: [
          if (filled && cellColor != null)
            Center(
              child: _buildSpecialOverlay(context, themeManager),
            ),
        ],
      ),
    );
  }

  Widget _buildSpecialOverlay(BuildContext context, ThemeManager themeManager) {
    if (isIce) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent.withOpacity(0.5),
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
