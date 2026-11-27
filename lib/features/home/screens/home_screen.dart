import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/analytics/session_tracker.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/gem_theme.dart';
import '../../../shared/widgets/gem_primary_button.dart';
import '../../../shared/widgets/level_background.dart';
import '../../ads/services/ad_lifecycle_observer.dart';
import '../../ads/services/ad_mediator.dart';
import '../../endless/controllers/endless_game_controller.dart';
import '../../endless/screens/endless_game_screen.dart';
import '../../game/screens/game_screen.dart';
import '../../game/services/game_feedback.dart';
import '../../game/services/score_share_service.dart';
import '../../journey/controllers/level_game_controller.dart';
import '../../journey/models/level.dart';
import '../../journey/services/app_bootstrap.dart';
import '../../journey/services/progress_lifecycle_observer.dart';
import '../../update/logic/version_check.dart';
import '../../update/services/store_launcher.dart';
import '../../update/widgets/update_popup.dart';

/// Home (mockup M-1, State A/B): level hiện tại, nút PLAY, Settings.
/// Không có Daily Gift (FR10.2) và không có chọn theme (FR10.3).
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.services,
    this.feedback,
    this.storeLauncher = const UrlStoreLauncher(),
  });

  /// Mở trang cửa hàng từ popup cập nhật (u4-update-and-share).
  final StoreLauncher storeLauncher;

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
  late final AdLifecycleObserver _adObserver;

  /// Chặn bấm PLAY hai lần trong lúc interstitial đang hiện.
  bool _starting = false;

  AdsService get _ads => widget.services.ads;

  /// Chia sẻ kèm link cửa hàng của nền tảng đang chạy (FR7, BR9.1).
  ScoreShareService get _shareService => PlatformScoreShareService(
    storeUrl: VersionCheck.storeUrlFor(
      widget.services.adsSettings,
      ios: defaultTargetPlatform == TargetPlatform.iOS,
    ),
  );

  @override
  void initState() {
    super.initState();
    // WF7: app vào nền thì ghi lại các key dirty.
    _lifecycleObserver = ProgressLifecycleObserver(widget.services.progress)
      ..attach();
    // FR4.1, AC1.6.2: đo phiên chơi từ lúc vào Home.
    _sessionObserver = _SessionLifecycleObserver(widget.services.session)
      ..attach();
    // u1-ads-core: đếm lần quay lại từ nền (BR5.1), và sau khung hình đầu
    // của Home thì hỏi đồng ý rồi tải trước quảng cáo (BR3.4, BR4.6).
    _adObserver = AdLifecycleObserver(_ads)..attach();
    if (_ads.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_ads.start());
      });
    }
    // u4-update-and-share: kiểm tra bản mới sau khung hình đầu, sau khi luồng
    // đồng ý xong và sau mỗi lần mở được ghi (BR8.4, BR8.5, NFR1.2).
    _ads.bannerChanges.addListener(_maybeShowUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowUpdate());
  }

  bool _checkingUpdate = false;

  /// Hiện popup cập nhật khi có bản mới, tối đa một lần mỗi lần mở ứng dụng,
  /// chỉ khi Home là màn trên cùng (BR8.4, BR8.5). Không chặn PLAY.
  Future<void> _maybeShowUpdate() async {
    final updates = widget.services.updates;
    if (updates == null || _checkingUpdate || !mounted) return;
    if (_ads.isActive && !_ads.startupSettled) return;
    final appOpen = _ads.appOpenCount;
    if (!updates.canShowFor(appOpen)) return;
    _checkingUpdate = true;
    final url = await updates.check();
    _checkingUpdate = false;
    if (url == null || !mounted || _starting) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
    if (!updates.canShowFor(appOpen)) return;
    updates.markShown(appOpen);
    final palette = GemTheme.forGem(widget.services.journey.currentLevel.gemId);
    await showUpdatePopup(
      context,
      palette: palette,
      onUpdate: () {
        // Quay lại từ cửa hàng không phải một lần mở mới (BR5.3).
        _ads.suppressNextResume();
        unawaited(widget.storeLauncher.open(url));
      },
    );
  }

  @override
  void dispose() {
    _ads.bannerChanges.removeListener(_maybeShowUpdate);
    _lifecycleObserver.detach();
    _sessionObserver.detach();
    _adObserver.detach();
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

  /// Mỗi lần bấm PLAY là một lần bấm Start: interstitial có thể hiện trước
  /// khi vào màn chơi (BR4.1 đến BR4.3). Không có quảng cáo thì mở ngay.
  void _withInterstitial(VoidCallback open) {
    if (!_ads.isActive) {
      open();
      return;
    }
    if (_starting) return;
    _starting = true;
    unawaited(
      _ads.interstitialIfDue().whenComplete(() {
        _starting = false;
        if (mounted) open();
      }),
    );
  }

  void _startEndless() => _withInterstitial(_openEndless);

  void _openEndless() {
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
          child: EndlessGameScreen(
            background: background,
            ads: services.ads,
            shareService: _shareService,
          ),
        ),
      ),
    ).then((_) {
      // BEST có thể đã đổi sau ván endless.
      if (mounted) setState(() {});
      unawaited(_maybeShowUpdate());
    });
  }

  void _startGame() => _withInterstitial(_openGame);

  void _openGame() {
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
            ads: services.ads,
            rewardEnabled: services.adsSettings.rewardEnabled,
            pendingLoss: services.pendingLoss,
          )..start(level, resumeSaved: true),
          child: GameScreen(ads: services.ads, shareService: _shareService),
        ),
      ),
    ).then((_) {
      // Level hiện tại (và màu gem) có thể đã đổi sau ván chơi.
      if (mounted) setState(() {});
      unawaited(_maybeShowUpdate());
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
