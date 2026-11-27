import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../../core/theme/gem_theme.dart';
import '../../../shared/widgets/level_background.dart';
import '../../../shared/widgets/level_progress_bar.dart';
import '../../ads/services/ad_mediator.dart';
import '../../ads/widgets/ad_banner_slot.dart';
import '../../journey/controllers/level_game_controller.dart';
import '../../journey/services/background_image_service.dart';
import '../../victory/widgets/victory_overlay.dart';
import '../services/score_share_service.dart';
import '../widgets/board_play_area.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/quit_dialog.dart';

/// Màn chơi một level. Chỉ render: state và quy tắc nằm ở
/// [LevelGameController]; widget chỉ đổi tọa độ chạm thành ô trên lưới.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    this.shareService = const PlatformScoreShareService(),
    this.images,
    this.ads = const NoopAdsService(),
  });

  final ScoreShareService shareService;

  /// Quảng cáo (u1-ads-core): interstitial trước PLAY AGAIN.
  final AdsService ads;

  /// Nạp ảnh nền; mặc định là bản dùng chung của app.
  final BackgroundImageService? images;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  final ScreenshotController _screenshotController = ScreenshotController();

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

  /// App vào nền khi đang chơi thì lưu ván dở để chơi tiếp lần sau.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.paused) return;
    context.read<LevelGameController>().saveOnPause();
  }

  /// `levelIndex` đã được nạp sẵn ảnh của level kế tiếp (AC7.3.1).
  int? _precachedAfter;

  BackgroundImageService get _images =>
      widget.images ?? BackgroundImageService.instance;

  /// Nạp sẵn ảnh của level N+1 một lần cho mỗi level đang chơi (FR5.4).
  void _precacheUpcoming(LevelGameController controller) {
    final current = controller.level.levelIndex;
    if (_precachedAfter == current) return;
    _precachedAfter = current;
    final upcoming = controller.upcomingLevel;
    if (upcoming == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_images.precache(context, upcoming));
    });
  }

  // ----- Điều hướng -----

  bool _quitDialogOpen = false;

  /// [←], back hệ thống và BACK TO MENU. Khi đang chơi thì hỏi "Quit this
  /// level?" trước (FR11.2); khi `resolving` thì bỏ qua (BR5.4).
  Future<void> _leave(LevelGameController controller) async {
    if (controller.needsQuitConfirmation) {
      if (_quitDialogOpen) return;
      _quitDialogOpen = true;
      final quit = await showQuitDialog(
        context,
        GemTheme.forGem(controller.level.gemId),
      );
      _quitDialogOpen = false;
      if (!quit || !mounted) return;
      controller.confirmQuit();
    }
    if (!controller.requestBack()) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LevelGameController>();
    final palette = GemTheme.forGem(controller.level.gemId);
    _precacheUpcoming(controller);

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
                  level: controller.level,
                  blurred: true,
                  service: _images,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    RepaintBoundary(child: _buildHeader(controller, palette)),
                    // Vùng cao cố định cho chữ combo: hiện hay ẩn cũng không
                    // làm bảng và khay dịch chuyển.
                    SizedBox(
                      height: 44,
                      child: controller.comboText == null
                          ? null
                          : Center(
                              child:
                                  Text(
                                        controller.comboText!,
                                        style: const TextStyle(
                                          color: Colors.yellowAccent,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                      .animate()
                                      .scale(
                                        duration: 300.ms,
                                        curve: Curves.elasticOut,
                                      )
                                      .shake(),
                            ),
                    ),
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
                    // Banner dưới cùng (u3-banner): cao 0 khi không có
                    // banner; lớp phủ phía trên Stack vẫn che nó (BR7.6).
                    AdBannerSlot(ads: widget.ads),
                  ],
                ),
              ),
              ..._buildOverlays(controller, palette),
            ],
          ),
        ),
      ),
    );
  }

  /// Overlay theo trạng thái. `switch` liệt kê đủ 5 case, không có `default`.
  List<Widget> _buildOverlays(
    LevelGameController controller,
    GemPalette palette,
  ) {
    final overlays = <Widget>[];
    switch (controller.status) {
      case LevelStatus.won:
        overlays.add(_buildVictoryOverlay(controller, palette));
      case LevelStatus.lost:
        overlays.add(_buildGameOverOverlay(controller, palette));
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

  Widget _buildHeader(LevelGameController controller, GemPalette palette) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
      child: Row(
        children: [
          IconButton(
            key: const Key('game-back-button'),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => unawaited(_leave(controller)),
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
                if (controller.bestScore > 0)
                  Text(
                    'BEST ${controller.bestScore}',
                    key: const Key('game-best-score'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 1.1,
                    ),
                  ),
                const SizedBox(height: 6),
                LevelProgressBar(
                  percent: controller.progressPercent,
                  palette: palette,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Màn Victory (U3): biến thể theo kết quả thắng.
  Widget _buildVictoryOverlay(
    LevelGameController controller,
    GemPalette palette,
  ) {
    return VictoryOverlay(
      variant: controller.victoryVariant,
      level: controller.level,
      score: controller.score,
      target: controller.targetScore,
      best: controller.bestScore,
      images: _images,
      onContinue: controller.continueAfterWin,
      onBackToMenu: () => unawaited(_leave(controller)),
      onShare: () {
        // Bảng chia sẻ đóng lại không phải một lần mở ứng dụng (BR5.3).
        widget.ads.suppressNextResume();
        return widget.shareService.shareVictory(
          screenshot: _screenshotController,
          levelName: controller.level.displayName,
          score: controller.score,
        );
      },
    );
  }

  /// Game Over của chế độ level (FR11.3): có Target và Rough Stone sẽ quay về.
  Widget _buildGameOverOverlay(
    LevelGameController controller,
    GemPalette palette,
  ) {
    final returnTo = controller.outcome?.nextLevel ?? controller.returnLevel;
    return GameOverOverlay(
      score: controller.score,
      target: controller.targetScore,
      returnLevelName: returnTo.displayName,
      palette: palette,
      onShare: () {
        widget.ads.suppressNextResume();
        unawaited(
          widget.shareService.shareScore(
            screenshot: _screenshotController,
            score: controller.score,
          ),
        );
      },
      onPlayAgain: () => _playAgain(controller),
      onMenu: () => unawaited(_leave(controller)),
      // Nút reward chỉ có khi ván thua này còn được thưởng (BR6.1, BR6.5).
      onWatchAd: controller.canWatchAd
          ? () => unawaited(controller.watchAd())
          : null,
      watchAdBusy: controller.watchingAd,
    );
  }

  bool _playingAgain = false;

  /// PLAY AGAIN là một lần bấm Start (BR4.1): interstitial có thể hiện trước
  /// khi bắt đầu lại. Không có quảng cáo thì bắt đầu ngay.
  void _playAgain(LevelGameController controller) {
    final ads = widget.ads;
    if (!ads.isActive) {
      controller.playAgain();
      return;
    }
    if (_playingAgain) return;
    _playingAgain = true;
    unawaited(
      ads.interstitialIfDue().whenComplete(() {
        _playingAgain = false;
        if (mounted) controller.playAgain();
      }),
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
            const Icon(
              Icons.touch_app,
              color: Colors.cyanAccent,
              size: 50,
            ).animate(onPlay: (c) => c.repeat()).slideY(begin: 0.2, end: 0),
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
