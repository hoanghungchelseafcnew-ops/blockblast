import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/log/gj_log.dart';
import '../../core/theme/gem_theme.dart';
import '../../features/journey/models/level.dart';
import '../../features/journey/services/background_image_service.dart';

/// Lớp phủ lên ảnh nền.
enum BackgroundOverlay {
  /// Không phủ (Victory, ảnh rõ nét).
  none,

  /// Đen 50% (màn chơi, design-system-mapping, Nền).
  dim,

  /// Gradient màu đá quý (Home).
  gem,
}

/// Ảnh nền của một level (FR5.1..FR5.3).
///
/// - Asset hiện ngay. Ảnh mạng tải xong thì cross-fade 300ms đè lên; ảnh mạng
///   lỗi thì giữ asset (AC7.2.2).
/// - Asset cũng lỗi thì chỉ còn gradient của gem bên dưới.
/// - [blurred]: blur sigma 12 phía sau board (FR5.3).
class LevelBackground extends StatelessWidget {
  const LevelBackground({
    super.key,
    required this.level,
    this.blurred = false,
    this.overlay = BackgroundOverlay.dim,
    this.service,
  });

  static const double blurSigma = 12;
  static const Duration crossFade = Duration(milliseconds: 300);

  final Level level;
  final bool blurred;
  final BackgroundOverlay overlay;
  final BackgroundImageService? service;

  @override
  Widget build(BuildContext context) {
    final images = service ?? BackgroundImageService.instance;
    final palette = GemTheme.forGem(level.gemId);
    final gradient = GemTheme.backgroundGradient(palette);
    final network = images.networkFor(level);

    Widget pictures = Stack(
      fit: StackFit.expand,
      children: [
        Image(
          key: const Key('level-bg-asset'),
          image: images.assetFor(level),
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, Object e, __) {
            GjLog.warn(
              'Background',
              'asset failed: levelId=${level.levelIndex}',
              e,
            );
            return const SizedBox.shrink();
          },
        ),
        if (network != null)
          Image(
            key: const Key('level-bg-network'),
            image: network,
            fit: BoxFit.cover,
            frameBuilder: (_, child, frame, wasSync) {
              if (wasSync) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: crossFade,
                curve: Curves.easeInOut,
                child: child,
              );
            },
            errorBuilder: (_, Object e, __) {
              GjLog.warn(
                'Background',
                'network failed, keeping asset: levelId=${level.levelIndex}',
                e,
              );
              return const SizedBox.shrink();
            },
          ),
      ],
    );

    if (blurred) {
      pictures = ImageFiltered(
        key: const Key('level-bg-blur'),
        imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: pictures,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          key: const Key('level-bg-gradient'),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradient,
            ),
          ),
        ),
        pictures,
        switch (overlay) {
          BackgroundOverlay.none => const SizedBox.shrink(),
          BackgroundOverlay.dim => const ColoredBox(
            key: Key('level-bg-dim'),
            color: Color(0x80000000),
          ),
          BackgroundOverlay.gem => DecoratedBox(
            key: const Key('level-bg-gem-tint'),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [for (final c in gradient) c.withValues(alpha: 0.8)],
              ),
            ),
          ),
        },
      ],
    );
  }
}
