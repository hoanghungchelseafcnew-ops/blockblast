import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../../core/theme/gem_theme.dart';
import '../../../shared/widgets/level_background.dart';
import '../../game/services/score_share_service.dart';
import '../../game/widgets/board_play_area.dart';
import '../../game/widgets/game_over_overlay.dart';
import '../../game/widgets/quit_dialog.dart';
import '../../journey/models/level.dart';
import '../../journey/services/background_image_service.dart';
import '../controllers/endless_game_controller.dart';
import '../models/endless_state.dart';

/// Màn chơi endless sau Journey Complete (FR9). Chỉ render: state và quy tắc
/// nằm ở [EndlessGameController]. Nền là level 36 (Ruby · Bling), bảng màu Ruby.
class EndlessGameScreen extends StatefulWidget {
  const EndlessGameScreen({
    super.key,
    required this.background,
    this.shareService = const PlatformScoreShareService(),
    this.images,
  });

  /// Level dùng làm ảnh nền (level 36).
  final Level background;
  final ScoreShareService shareService;
  final BackgroundImageService? images;

  @override
  State<EndlessGameScreen> createState() => _EndlessGameScreenState();
}

class _EndlessGameScreenState extends State<EndlessGameScreen>
    with WidgetsBindingObserver {
  static final GemPalette _palette = GemTheme.forGem('ruby');

  final ScreenshotController _screenshotController = ScreenshotController();
  bool _quitDialogOpen = false;

  BackgroundImageService get _images =>
      widget.images ?? BackgroundImageService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// App vào nền khi đang chơi thì lưu điểm (ER5).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.paused) return;
    unawaited(context.read<EndlessGameController>().saveOnPause());
  }

  /// [←], back hệ thống và BACK TO MENU. Đang chơi thì hỏi "Quit?" (ER4).
  Future<void> _leave(EndlessGameController controller) async {
    if (controller.needsQuitConfirmation) {
      if (_quitDialogOpen) return;
      _quitDialogOpen = true;
      final quit = await showQuitDialog(
        context,
        _palette,
        mode: QuitMode.endless,
      );
      _quitDialogOpen = false;
      if (!quit || !mounted) return;
      await controller.confirmQuit();
      if (!mounted) return;
    }
    if (!controller.requestBack()) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EndlessGameController>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leave(controller));
      },
      child: Screenshot(
        controller: _screenshotController,
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: LevelBackground(
                  level: widget.background,
                  blurred: true,
                  service: _images,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    RepaintBoundary(child: _buildHeader(controller)),
                    Expanded(
                      child: BoardPlayArea(
                        board: controller.board,
                        tray: controller.tray,
                        activeBlock: controller.activeBlock,
                        onDragStart: controller.onDragStart,
                        onPreview: controller.updatePreview,
                        onPlace: (row, col) =>
                            unawaited(controller.placeAt(row, col)),
                        onCancel: controller.cancelDrag,
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.status == EndlessStatus.lost)
                GameOverOverlay.endless(
                  score: controller.score,
                  best: controller.bestScore,
                  palette: _palette,
                  onShare: () => unawaited(
                    widget.shareService.shareScore(
                      screenshot: _screenshotController,
                      score: controller.score,
                    ),
                  ),
                  onPlayAgain: controller.playAgain,
                  onMenu: () => unawaited(_leave(controller)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(EndlessGameController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
      child: Row(
        children: [
          IconButton(
            key: const Key('endless-back-button'),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => unawaited(_leave(controller)),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Endless',
                  key: Key('endless-title'),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'SCORE ${controller.score}',
                  key: const Key('endless-score'),
                  style: const TextStyle(color: Colors.white, fontSize: 28),
                ),
                Text(
                  'BEST ${controller.bestScore}',
                  key: const Key('endless-best'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
