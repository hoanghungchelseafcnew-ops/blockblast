import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/theme_manager.dart';
import '../../../core/widgets/animated_background.dart';
import '../../journey/controllers/level_game_controller.dart';
import '../engine/board_geometry.dart';
import '../models/block_model.dart';
import '../services/score_share_service.dart';
import '../widgets/block_palette.dart';
import '../widgets/game_board.dart';

/// Màn chơi một level. Chỉ render: state và quy tắc nằm ở
/// [LevelGameController]; widget chỉ đổi tọa độ chạm thành ô trên lưới.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    this.shareService = const PlatformScoreShareService(),
  });

  final ScoreShareService shareService;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey _boardKey = GlobalKey();
  final ScreenshotController _screenshotController = ScreenshotController();
  Offset? _lastDragPosition;

  // ----- Kéo-thả: đổi tọa độ thành ô rồi giao cho controller -----

  BoardCellPosition? _cellAt(Offset global, BlockModel block) {
    final box = _boardKey.currentContext?.findRenderObject();
    if (box is! RenderBox) return null;
    return BoardGeometry.cellFor(
      local: box.globalToLocal(global),
      boardWidth: box.size.width,
      block: block,
    );
  }

  void _onDragUpdate(LevelGameController controller, Offset global) {
    final block = controller.activeBlock;
    if (block == null) return;
    _lastDragPosition = global;
    final cell = _cellAt(global, block);
    if (cell == null) return;
    controller.updatePreview(cell.row, cell.col);
  }

  void _onDragEnd(LevelGameController controller) {
    final block = controller.activeBlock;
    final drag = _lastDragPosition;
    _lastDragPosition = null;
    final cell = (block == null || drag == null) ? null : _cellAt(drag, block);
    if (cell == null) {
      controller.cancelDrag();
      return;
    }
    unawaited(controller.placeAt(cell.row, cell.col));
  }

  // ----- Điều hướng -----

  void _leave(LevelGameController controller) {
    if (!controller.requestBack()) return; // resolving: bỏ qua (BR5.4)
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LevelGameController>();
    final themeBgGradient = context.watch<ThemeManager>().backgroundGradient;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave(controller);
      },
      child: Screenshot(
        controller: _screenshotController,
        child: Scaffold(
          body: Stack(
            children: [
              AnimatedBackground(colors: themeBgGradient),
              SafeArea(
                child: Column(
                  children: [
                    RepaintBoundary(child: _buildHeader(controller)),
                    if (controller.comboText != null)
                      Text(
                        controller.comboText!,
                        style: const TextStyle(
                          color: Colors.yellowAccent,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().scale(duration: 300.ms, curve: Curves.elasticOut).shake(),
                    const Spacer(),
                    RepaintBoundary(
                      child: Container(
                        key: _boardKey,
                        child: GameBoard(board: controller.board),
                      ),
                    ),
                    const Spacer(),
                    RepaintBoundary(child: _buildPalette(controller)),
                  ],
                ),
              ),
              ..._buildOverlays(controller),
            ],
          ),
        ),
      ),
    );
  }

  /// Overlay theo trạng thái. `switch` liệt kê đủ 5 case, không có `default`.
  List<Widget> _buildOverlays(LevelGameController controller) {
    final overlays = <Widget>[];
    switch (controller.status) {
      case LevelStatus.won:
        overlays.add(_buildVictoryOverlay(controller));
      case LevelStatus.lost:
        overlays.add(_buildGameOverOverlay(controller));
      case LevelStatus.playing:
      case LevelStatus.resolving:
      case LevelStatus.quit:
        break;
    }
    if (controller.tutorialActive) {
      overlays.add(IgnorePointer(child: _buildTutorial()));
    }
    return overlays;
  }

  Widget _buildHeader(LevelGameController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
      child: Row(
        children: [
          IconButton(
            key: const Key('game-back-button'),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _leave(controller),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  controller.level.displayName,
                  key: const Key('game-level-name'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${controller.score} / ${controller.targetScore}',
                  key: const Key('game-score-target'),
                  style: const TextStyle(color: Colors.white, fontSize: 28),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          key: const Key('game-progress-bar'),
                          minHeight: 8,
                          value: controller.progressPercent / 100,
                          backgroundColor: Colors.white12,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${controller.progressPercent}%',
                      key: const Key('game-progress-label'),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPalette(LevelGameController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: BlockPalette(
        blocks: controller.tray,
        onDragStart: controller.onDragStart,
        onDragUpdate: (global) => _onDragUpdate(controller, global),
        onDragEnd: () => _onDragEnd(controller),
      ),
    );
  }

  /// Victory tạm của U1; U3 thay bằng bản đầy đủ.
  Widget _buildVictoryOverlay(LevelGameController controller) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        key: const Key('victory-overlay'),
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.yellowAccent, size: 80),
              const Text(
                'Level Complete!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${controller.score} / ${controller.targetScore}',
                key: const Key('victory-score'),
                style: const TextStyle(color: Colors.white70, fontSize: 24),
              ),
              const SizedBox(height: 40),
              _buildOverlayButton(
                'CONTINUE',
                Icons.arrow_forward,
                AppColors.primary,
                controller.continueAfterWin,
                key: const Key('victory-continue-button'),
              ),
            ],
          ).animate().fade().scale(),
        ),
      ),
    );
  }

  /// Game Over cũ của U1 (BR5.7). U2 thay bằng bản mới.
  Widget _buildGameOverOverlay(LevelGameController controller) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        key: const Key('game-over-overlay'),
        color: Colors.black.withValues(alpha: 0.7),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.yellowAccent, size: 80),
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
                'FINAL SCORE: ${controller.score}',
                style: const TextStyle(color: Colors.white70, fontSize: 24),
              ),
              const SizedBox(height: 40),
              _buildOverlayButton(
                'SHARE SCORE',
                Icons.share,
                Colors.blueAccent,
                () => unawaited(widget.shareService.shareScore(
                  screenshot: _screenshotController,
                  score: controller.score,
                )),
                key: const Key('game-over-share-button'),
              ),
              const SizedBox(height: 12),
              _buildOverlayButton(
                'PLAY AGAIN',
                Icons.replay,
                AppColors.primary,
                controller.playAgain,
                key: const Key('game-over-play-again-button'),
              ),
              if (controller.canRevive) ...[
                const SizedBox(height: 12),
                _buildOverlayButton(
                  'REVIVE (FREE)',
                  Icons.flash_on,
                  Colors.greenAccent,
                  controller.revive,
                  key: const Key('game-over-revive-button'),
                ),
              ],
              const SizedBox(height: 12),
              TextButton(
                key: const Key('game-over-menu-button'),
                onPressed: () => _leave(controller),
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

  Widget _buildOverlayButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    Key? key,
  }) {
    return SizedBox(
      width: 220,
      child: ElevatedButton.icon(
        key: key,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(220, 52),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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

  Widget _buildTutorial() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.touch_app, color: Colors.cyanAccent, size: 50)
                .animate(onPlay: (c) => c.repeat())
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 12),
            const Text(
              'DRAG BLOCKS TO THE BOARD!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Fill rows or columns to clear them!',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ).animate().fade().scale(),
    );
  }
}
