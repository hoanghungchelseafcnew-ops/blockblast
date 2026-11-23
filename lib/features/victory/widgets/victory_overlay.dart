import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/config/level_config.dart';
import '../../../core/log/gj_log.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/gem_theme.dart';
import '../../../shared/widgets/gem_primary_button.dart';
import '../../../shared/widgets/level_background.dart';
import '../../journey/models/level.dart';
import '../../journey/services/background_image_service.dart';
import '../models/victory_variant.dart';
import 'confetti_layer.dart';
import 'gem_unlock_animation.dart';

/// Màn Victory (mockup M-4, M-5, M-5a; FR6.1..FR6.4).
///
/// - CONTINUE hiện và bấm được ngay, có focus mặc định, và chỉ nhận lần bấm
///   đầu tiên (AC3.1.3, AC3.2.3).
/// - Level 36 không có CONTINUE, chỉ có BACK TO MENU (AC3.3.2).
/// - Giảm chuyển động: bỏ confetti và xoay, giữ fade và đủ chữ (AC3.4.2).
class VictoryOverlay extends StatefulWidget {
  const VictoryOverlay({
    super.key,
    required this.variant,
    required this.level,
    required this.score,
    required this.target,
    required this.best,
    this.onContinue,
    this.onBackToMenu,
    this.onShare,
    this.images,
  });

  static const Duration enter = Duration(milliseconds: 400);
  static const Duration enterFinal = Duration(milliseconds: 500);

  final VictoryVariant variant;
  final Level level;
  final int score;
  final int target;
  final int best;
  final VoidCallback? onContinue;
  final VoidCallback? onBackToMenu;

  /// Chia sẻ ảnh toàn màn hình (FR3.1); null thì ẩn nút SHARE.
  final Future<void> Function()? onShare;
  final BackgroundImageService? images;

  @override
  State<VictoryOverlay> createState() => _VictoryOverlayState();
}

class _VictoryOverlayState extends State<VictoryOverlay> {
  bool _leaving = false;
  bool _sharing = false;

  void _once(VoidCallback? action) {
    if (_leaving || action == null) return;
    setState(() => _leaving = true);
    action();
  }

  /// SHARE không đánh dấu rời màn; bấm lại khi đang chia sẻ bị bỏ qua
  /// (BR1.5). Lỗi của [VictoryOverlay.onShare] chỉ được ghi log (BR1.4).
  Future<void> _share() async {
    final action = widget.onShare;
    if (_sharing || _leaving || action == null) return;
    setState(() => _sharing = true);
    try {
      await action();
    } catch (e) {
      GjLog.error('Game', 'victory share failed', e);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final variant = widget.variant;
    final level = widget.level;
    final palette = GemTheme.forGem(level.gemId);
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final isFinal = variant == VictoryVariant.journeyComplete;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFinal) ...[
          _GemsRow(reducedMotion: reducedMotion),
          const SizedBox(height: 12),
        ],
        if (variant == VictoryVariant.gemUnlock) ...[
          GemUnlockAnimation(palette: palette, reducedMotion: reducedMotion),
          const SizedBox(height: 8),
        ],
        if (variant != VictoryVariant.sub) ...[
          Text(
            '🎉 ${level.gemName} Unlocked!',
            key: const Key('victory-unlock-text'),
            textAlign: TextAlign.center,
            style: AppTypography.headline(size: 26),
          ),
          const SizedBox(height: 12),
        ],
        FractionallySizedBox(
          widthFactor: 0.85,
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              key: const Key('victory-image'),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: palette.primary.withValues(alpha: 0.7),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LevelBackground(
                  level: level,
                  overlay: BackgroundOverlay.none,
                  service: widget.images,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Semantics(
          header: true,
          child: Text(
            isFinal ? 'JOURNEY COMPLETE!' : 'Level Complete!',
            key: const Key('victory-title'),
            textAlign: TextAlign.center,
            style: isFinal
                ? AppTypography.display(size: 40)
                : AppTypography.headline(),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isFinal
              ? 'You have collected all 6 gems'
              : 'Congratulations! ${level.subName} Completed!',
          key: const Key('victory-subtitle'),
          textAlign: TextAlign.center,
          style: AppTypography.body(),
        ),
        const SizedBox(height: 6),
        Text(
          '${widget.score} / ${widget.target} · BEST ${widget.best}',
          key: const Key('victory-score'),
          style: AppTypography.caption(),
        ),
        const SizedBox(height: 24),
        if (variant.canContinue)
          GemPrimaryButton(
            key: const Key('victory-continue-button'),
            label: 'CONTINUE',
            icon: Icons.arrow_forward,
            palette: palette,
            width: 240,
            autofocus: true,
            onPressed: _leaving ? null : () => _once(widget.onContinue),
          )
        else
          GemPrimaryButton(
            key: const Key('victory-menu-button'),
            label: 'BACK TO MENU',
            palette: palette,
            width: 240,
            autofocus: true,
            onPressed: _leaving ? null : () => _once(widget.onBackToMenu),
          ),
        if (widget.onShare != null) ...[
          const SizedBox(height: 12),
          GemPrimaryButton(
            key: const Key('victory-share-button'),
            label: 'SHARE',
            icon: Icons.share,
            palette: palette,
            width: 240,
            onPressed: _leaving || _sharing ? null : () => _share(),
          ),
        ],
      ],
    );

    return Stack(
      key: const Key('victory-overlay'),
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xE6000000)),
        if (!reducedMotion && !_leaving)
          ConfettiLayer(
            key: const Key('confetti-layer'),
            colors: [palette.primary, palette.secondary, Colors.white],
          ),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: content,
            ),
          ),
        ),
      ],
    ).animate().fade(
      duration: isFinal ? VictoryOverlay.enterFinal : VictoryOverlay.enter,
      curve: Curves.easeInOut,
    );
  }
}

/// Sáu viên đá lần lượt sáng lên ở màn Journey Complete (M-5a).
class _GemsRow extends StatelessWidget {
  const _GemsRow({required this.reducedMotion});

  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('victory-gems-row'),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < GemIds.all.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _gem(GemIds.all[i], i),
          ),
      ],
    );
  }

  Widget _gem(String gemId, int index) {
    final icon = Icon(
      Icons.diamond,
      size: 36,
      color: GemTheme.forGem(gemId).primary,
    );
    if (reducedMotion) return icon;
    return icon
        .animate(delay: (200 * index).ms)
        .fade(duration: 300.ms, curve: Curves.easeInOut)
        .scale(duration: 300.ms, curve: Curves.easeInOut);
  }
}
