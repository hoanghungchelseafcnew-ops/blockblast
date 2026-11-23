import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/gem_theme.dart';

/// Viên đá 2D khi mở khóa (FR6.2, AC3.2.2: không dùng 3D): scale 0→1, xoay
/// 360°, shimmer 1.5 giây. Khi [reducedMotion] chỉ fade in, không xoay.
class GemUnlockAnimation extends StatelessWidget {
  const GemUnlockAnimation({
    super.key,
    required this.palette,
    this.size = 96,
    this.reducedMotion = false,
  });

  final GemPalette palette;
  final double size;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final gem = Icon(
      Icons.diamond,
      key: const Key('gem-unlock-icon'),
      size: size,
      color: palette.primary,
      shadows: [
        Shadow(color: palette.primary.withValues(alpha: 0.8), blurRadius: 24),
      ],
    );
    if (reducedMotion) {
      return gem.animate().fade(duration: 400.ms, curve: Curves.easeInOut);
    }
    return gem
        .animate()
        .scale(
          begin: Offset.zero,
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.easeInOut,
        )
        .rotate(begin: 0, end: 1, duration: 1500.ms, curve: Curves.easeInOut)
        .shimmer(duration: 1500.ms, color: Colors.white);
  }
}
