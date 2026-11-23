import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/gem_theme.dart';

/// Nút chính theo màu đá quý: PLAY, CONTINUE, PLAY AGAIN, QUIT
/// (design-system-mapping, `GemPrimaryButton`).
class GemPrimaryButton extends StatelessWidget {
  const GemPrimaryButton({
    super.key,
    required this.label,
    required this.palette,
    required this.onPressed,
    this.icon,
    this.width = 220,
    this.height = minHeight,
    this.autofocus = false,
  });

  /// Chiều cao tối thiểu theo design system (≥ 48dp của NFR9).
  static const double minHeight = 56;

  final String label;
  final GemPalette palette;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double width;
  final double height;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      backgroundColor: palette.buttonFill,
      foregroundColor: palette.onPrimary,
      minimumSize: Size(width, height < minHeight ? minHeight : height),
      // Padding ngang nhỏ: theme chung đặt 40dp mỗi bên, làm nhãn dài như
      // "CONTINUE" bị xuống dòng trong nút 220dp.
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      shadowColor: palette.primary.withValues(alpha: 0.5),
    );
    // Nhãn luôn một dòng; nếu vẫn thiếu chỗ thì thu nhỏ chữ thay vì xuống dòng.
    final text = FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
        style: AppTypography.title(color: palette.onPrimary),
      ),
    );
    final iconData = icon;
    return SizedBox(
      width: width,
      child: iconData == null
          ? ElevatedButton(
              style: style,
              autofocus: autofocus,
              onPressed: onPressed,
              child: text,
            )
          : ElevatedButton.icon(
              style: style,
              autofocus: autofocus,
              onPressed: onPressed,
              icon: Icon(iconData, size: 28, color: palette.onPrimary),
              label: text,
            ),
    );
  }
}
