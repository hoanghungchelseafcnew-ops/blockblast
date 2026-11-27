import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/gem_theme.dart';
import '../../../shared/widgets/gem_primary_button.dart';

/// Màn Game Over của chế độ level (FR11.3, AC2.6.1, AC2.6.2). Khi có
/// [onWatchAd], nút WATCH AD TO TRY AGAIN là nút chính và PLAY AGAIN thành
/// nút phụ (u2-reward-ads, BR6.1).
class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.score,
    required int this.target,
    required String this.returnLevelName,
    required this.palette,
    required this.onShare,
    required this.onPlayAgain,
    required this.onMenu,
    this.onWatchAd,
    this.watchAdBusy = false,
  }) : best = null;

  /// Game Over của chế độ endless (FR9): FINAL SCORE và BEST, không có Target
  /// hay level để quay về.
  const GameOverOverlay.endless({
    super.key,
    required this.score,
    required int this.best,
    required this.palette,
    required this.onShare,
    required this.onPlayAgain,
    required this.onMenu,
  }) : target = null,
       returnLevelName = null,
       onWatchAd = null,
       watchAdBusy = false;

  final int score;
  final int? target;

  /// Nhãn `"<Gem> · Rough Stone"` của level người chơi sẽ quay về.
  final String? returnLevelName;

  /// BEST của endless; null ở chế độ level.
  final int? best;

  /// Màu của gem đang chơi (mockup M-3).
  final GemPalette palette;
  final VoidCallback onShare;
  final VoidCallback onPlayAgain;
  final VoidCallback onMenu;

  /// WATCH AD TO TRY AGAIN; null thì không có nút reward (BR6.1). Bản
  /// endless không bao giờ có nút này.
  final VoidCallback? onWatchAd;

  /// Quảng cáo reward đang hiện: nút reward bị khóa, các nút khác vẫn bấm
  /// được.
  final bool watchAdBusy;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        key: const Key('game-over-overlay'),
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'FINAL SCORE: $score',
                key: const Key('game-over-score'),
                style: const TextStyle(color: Colors.white70, fontSize: 24),
              ),
              const SizedBox(height: 4),
              if (best != null)
                Text(
                  'BEST: $best',
                  key: const Key('game-over-best'),
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                )
              else ...[
                Text(
                  'Target: $target',
                  key: const Key('game-over-target'),
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 16),
                const Text(
                  'You will return to',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  returnLevelName!,
                  key: const Key('game-over-return-level'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: palette.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ..._playButtons(),
              const SizedBox(height: 12),
              OverlayButton(
                label: 'SHARE SCORE',
                icon: Icons.share,
                color: Colors.blueAccent,
                onPressed: onShare,
                key: const Key('game-over-share-button'),
              ),
              const SizedBox(height: 12),
              TextButton(
                key: const Key('game-over-menu-button'),
                style: TextButton.styleFrom(minimumSize: const Size(220, 48)),
                onPressed: onMenu,
                child: const Text(
                  'BACK TO MENU',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ).animate().fade().scale(),
        ),
      ),
    );
  }

  /// Nút reward (nếu có) và PLAY AGAIN theo frontend-components.md.
  List<Widget> _playButtons() {
    final watchAd = onWatchAd;
    final playAgainPrimary = GemPrimaryButton(
      key: const Key('game-over-play-again-button'),
      label: 'PLAY AGAIN',
      icon: Icons.replay,
      palette: palette,
      onPressed: onPlayAgain,
    );
    if (watchAd == null) return [playAgainPrimary];
    return [
      const Text(
        'Watch an ad to stay on this level',
        key: Key('game-over-reward-hint'),
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
      const SizedBox(height: 8),
      GemPrimaryButton(
        key: const Key('game-over-reward-button'),
        label: 'WATCH AD TO TRY AGAIN',
        icon: Icons.ondemand_video,
        palette: palette,
        width: 260,
        onPressed: watchAdBusy ? null : watchAd,
      ),
      const SizedBox(height: 12),
      OverlayButton(
        key: const Key('game-over-play-again-button'),
        label: 'PLAY AGAIN',
        icon: Icons.replay,
        color: Colors.white24,
        onPressed: onPlayAgain,
      ),
    ];
  }
}

/// Nút lớn dùng chung cho các overlay của màn chơi (vùng chạm ≥ 48dp).
class OverlayButton extends StatelessWidget {
  const OverlayButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(220, 52),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
