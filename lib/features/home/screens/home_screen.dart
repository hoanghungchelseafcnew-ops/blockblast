import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/analytics/session_tracker.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/gem_theme.dart';
import '../../../shared/widgets/gem_primary_button.dart';
import '../../../shared/widgets/level_background.dart';
import '../../endless/controllers/endless_game_controller.dart';
import '../../endless/screens/endless_game_screen.dart';
import '../../game/screens/game_screen.dart';
import '../../game/services/game_feedback.dart';
import '../../journey/controllers/level_game_controller.dart';
import '../../journey/models/level.dart';
import '../../journey/services/app_bootstrap.dart';
import '../../journey/services/progress_lifecycle_observer.dart';

/// Home (mockup M-1, State A/B): level hiện tại, nút PLAY, Settings.
/// Không có Daily Gift (FR10.2) và không có chọn theme (FR10.3).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.services, this.feedback});

  /// Dịch vụ dựng ở bootstrap (constructor DI).
  final AppServices services;

  /// Âm thanh và rung cho ván chơi mới. Mặc định dùng `services.audio`.
  final GameFeedback? feedback;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ProgressLifecycleObserver _lifecycleObserver;
  late final _SessionLifecycleObserver _sessionObserver;

  @override
  void initState() {
    super.initState();
    // WF7: app vào nền thì ghi lại các key dirty.
    _lifecycleObserver = ProgressLifecycleObserver(widget.services.progress)
      ..attach();
    // FR4.1, AC1.6.2: đo phiên chơi từ lúc vào Home.
    _sessionObserver = _SessionLifecycleObserver(widget.services.session)
      ..attach();
  }

  @override
  void dispose() {
    _lifecycleObserver.detach();
    _sessionObserver.detach();
    super.dispose();
  }

  /// Settings chỉ còn Sound Effects (mockup M-1s, AC5.3.1). Lựa chọn được lưu
  /// ở `sound_muted` (AC5.3.2).
  void _openSettings(BuildContext context, GemPalette palette) {
    final audio = widget.services.audio;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          key: const Key('settings-sheet'),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C2E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SETTINGS', style: AppTypography.headline()),
              const SizedBox(height: 20),
              ListenableBuilder(
                listenable: audio,
                builder: (context, _) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      audio.isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 30,
                    ),
                    title: Text(
                      'Sound Effects',
                      style: AppTypography.body(size: 18),
                    ),
                    trailing: Switch(
                      key: const Key('settings-sound-switch'),
                      value: !audio.isMuted,
                      activeThumbColor: palette.primary,
                      onChanged: (on) => audio.setMuted(!on),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.services.journey.currentLevel;
    final palette = GemTheme.forGem(level.gemId);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: LevelBackground(
              level: level,
              blurred: true,
              overlay: BackgroundOverlay.gem,
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    key: const Key('home-settings-button'),
                    iconSize: 30,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () => _openSettings(context, palette),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                            'BLOCK\nJEWEL',
                            textAlign: TextAlign.center,
                            style: AppTypography.display(size: 60).copyWith(
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  color: palette.primary.withValues(alpha: 0.8),
                                  blurRadius: 25,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fade(duration: 800.ms)
                          .slideY(
                            begin: -0.2,
                            end: 0,
                            curve: Curves.easeOutBack,
                          ),
                      const SizedBox(height: 8),
                      Text(
                        '◆ Gemstone Journey ◆',
                        style: AppTypography.caption(),
                      ),
                      const SizedBox(height: 40),
                      (widget.services.journey.journeyCompleted
                              ? _buildCompleteCard(level, palette)
                              : _buildLevelCard(level, palette))
                          .animate(delay: 300.ms)
                          .fade()
                          .slideX(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Viên đá, nhãn level và nút PLAY (WF2, mockup M-1).
  Widget _buildLevelCard(Level level, GemPalette palette) {
    return Column(
      children: [
        Icon(
          Icons.diamond,
          key: const Key('home-gem-icon'),
          size: 96,
          color: palette.primary,
        ),
        const SizedBox(height: 12),
        Text(
          level.displayName,
          key: const Key('home-level-label'),
          style: AppTypography.title(),
        ),
        const SizedBox(height: 4),
        Text(
          'Level ${level.levelIndex} of ${Level.totalLevels}',
          key: const Key('home-level-number'),
          style: AppTypography.caption(),
        ),
        const SizedBox(height: 28),
        GemPrimaryButton(
          key: const Key('home-play-button'),
          label: 'PLAY',
          icon: Icons.play_arrow_rounded,
          palette: palette,
          width: 280,
          height: 64,
          onPressed: _startGame,
        ),
      ],
    );
  }

  /// State C (mockup M-1c): Journey Complete, 6 viên đá và nút PLAY mở endless.
  Widget _buildCompleteCard(Level level, GemPalette palette) {
    final best = widget.services.progress.endlessState.highScore;
    return Column(
      children: [
        Row(
          key: const Key('home-gem-row'),
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final id in GemTheme.gemIds)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.diamond,
                  size: 40,
                  color: GemTheme.forGem(id).primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Journey Complete',
          key: const Key('home-journey-complete'),
          style: AppTypography.title(),
        ),
        const SizedBox(height: 4),
        Text(
          best > 0 ? 'Endless · Best $best' : 'Endless · Best —',
          key: const Key('home-endless-best'),
          style: AppTypography.caption(),
        ),
        const SizedBox(height: 28),
        GemPrimaryButton(
          key: const Key('home-play-button'),
          label: 'PLAY',
          icon: Icons.play_arrow_rounded,
          palette: palette,
          width: 280,
          height: 64,
          onPressed: _startEndless,
        ),
      ],
    );
  }

  void _startEndless() {
    final services = widget.services;
    final background = services.journey.currentLevel;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider<EndlessGameController>(
          create: (_) => EndlessGameController(
            progress: services.progress,
            feedback: widget.feedback ?? DeviceGameFeedback(services.audio),
          )..start(resumeSaved: true),
          child: EndlessGameScreen(background: background),
        ),
      ),
    ).then((_) {
      // BEST có thể đã đổi sau ván endless.
      if (mounted) setState(() {});
    });
  }

  void _startGame() {
    final services = widget.services;
    final level = services.journey.currentLevel;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider<LevelGameController>(
          create: (_) => LevelGameController(
            journey: services.journey,
            progress: services.progress,
            feedback: widget.feedback ?? DeviceGameFeedback(services.audio),
            analytics: services.analytics,
          )..start(level, resumeSaved: true),
          child: const GameScreen(),
        ),
      ),
    ).then((_) {
      // Level hiện tại (và màu gem) có thể đã đổi sau ván chơi.
      if (mounted) setState(() {});
    });
  }
}

/// Nối vòng đời app với [SessionTracker]: `resumed` mở phiên, `paused` đóng
/// phiên (gửi `game_session`, cộng `total_play_time`).
class _SessionLifecycleObserver with WidgetsBindingObserver {
  _SessionLifecycleObserver(this._session);

  final SessionTracker? _session;

  void attach() {
    final session = _session;
    if (session == null) return;
    session.start();
    WidgetsBinding.instance.addObserver(this);
  }

  void detach() {
    if (_session == null) return;
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final session = _session;
    if (session == null) return;
    switch (state) {
      case AppLifecycleState.resumed:
        session.start();
      case AppLifecycleState.paused:
        unawaited(session.pause());
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }
}
