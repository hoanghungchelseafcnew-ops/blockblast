import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/gem_theme.dart';

/// Thanh tiến độ của level (design-system-mapping, `LevelProgressBar`).
///
/// Fill màu `primary` của gem, track `#FFFFFF1F`, viền trắng 1.5dp để thành
/// phần UI đạt tương phản ≥ 3:1 với mọi gem (NFR9), kèm nhãn % dạng chữ để
/// trạng thái không chỉ thể hiện bằng màu.
class LevelProgressBar extends StatelessWidget {
  const LevelProgressBar({
    super.key,
    required this.percent,
    required this.palette,
  });

  static const Color track = Color(0x1FFFFFFF);
  static const double borderWidth = 1.5;

  /// 0..100.
  final int percent;
  final GemPalette palette;

  @override
  Widget build(BuildContext context) {
    final value = percent.clamp(0, 100) / 100;
    return Row(
      children: [
        Expanded(
          child: DecoratedBox(
            key: const Key('game-progress-border'),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white, width: borderWidth),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                key: const Key('game-progress-bar'),
                minHeight: 8,
                value: value,
                backgroundColor: track,
                color: palette.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percent%',
          key: const Key('game-progress-label'),
          style: AppTypography.caption(),
        ),
      ],
    );
  }
}
