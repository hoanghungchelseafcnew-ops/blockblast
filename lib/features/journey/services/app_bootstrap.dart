import 'dart:async';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/analytics/firebase_analytics_service.dart';
import '../../../core/analytics/session_tracker.dart';
import '../../../core/audio/audio_controller.dart';
import '../../../core/config/level_config.dart';
import '../../../core/config/level_config_service.dart';
import '../../../core/config/remote_config_client.dart';
import '../../../core/firebase/firebase_gateway.dart';
import '../../../core/log/gj_log.dart';
import '../../../core/utils/clock.dart';
import '../controllers/journey_controller.dart';
import 'level_catalog.dart';
import 'progress_repository.dart';

/// Các dịch vụ sống suốt phiên, dựng xong ở bootstrap.
class AppServices {
  const AppServices({
    required this.config,
    required this.catalog,
    required this.progress,
    required this.journey,
    required this.audio,
    this.analytics = const NoopAnalyticsService(),
    this.session,
  });

  final LevelConfig config;
  final LevelCatalog catalog;
  final ProgressRepository progress;
  final JourneyController journey;

  /// Âm thanh; trạng thái tắt lưu ở `sound_muted` (FR13.2).
  final AudioController audio;

  /// Analytics (C4). Noop khi Firebase không khởi tạo được.
  final AnalyticsService analytics;

  /// Đo phiên chơi và `total_play_time` (FR4.1, FR8.1). Null thì không đo.
  final SessionTracker? session;
}

class BootstrapResult {
  const BootstrapResult({
    required this.services,
    required this.firebase,
    required this.fetch,
    required this.elapsed,
    required this.deadlineHit,
  });

  final AppServices services;
  final FirebaseStatus firebase;
  final FetchStatus fetch;
  final Duration elapsed;

  /// True nếu hạn chót cắt ngang một bước chưa xong (BR1.8).
  final bool deadlineHit;
}

/// Khởi động app trong hạn chót 3,5 giây (WF1, BR1.1, BR1.5, BR1.8).
///
/// `run()` không bao giờ throw và không bao giờ treo quá [deadline]: bước nào
/// chưa xong thì bị bỏ qua (dùng cached hoặc default).
class AppBootstrap {
  AppBootstrap({
    required FirebaseGateway gateway,
    required RemoteConfigClient Function() remoteConfigFactory,
    required ProgressRepository progress,
    Clock clock = const SystemClock(),
    SfxPlayer Function()? sfxPlayerFactory,
    AnalyticsService Function()? analyticsFactory,
    this.deadline = const Duration(milliseconds: 3500),
    this.fetchMax = const Duration(seconds: 2),
    this.localReserve = const Duration(milliseconds: 500),
    this.progressTimeout = const Duration(milliseconds: 500),
  }) : _gateway = gateway,
       _remoteConfigFactory = remoteConfigFactory,
       _progress = progress,
       _clock = clock,
       _sfxPlayerFactory = sfxPlayerFactory,
       _analyticsFactory = analyticsFactory ?? _firebaseAnalytics;

  final FirebaseGateway _gateway;
  final RemoteConfigClient Function() _remoteConfigFactory;
  final ProgressRepository _progress;
  final Clock _clock;
  final SfxPlayer Function()? _sfxPlayerFactory;
  final AnalyticsService Function() _analyticsFactory;

  /// Hạn chót tổng từ lúc bắt đầu đến lúc vào Home (BR1.8).
  final Duration deadline;

  /// Trần của một lần fetch (BR1.1).
  final Duration fetchMax;

  /// Thời gian dành cho đọc dữ liệu cục bộ, trừ khỏi ngân sách fetch.
  final Duration localReserve;

  /// Trần của `ProgressRepository.load` (BR1.8).
  final Duration progressTimeout;

  Future<BootstrapResult> run() async {
    final start = _clock.now();
    final state = _State();
    final stepsDone = _steps(start, state).then((_) => true);

    final guard = Completer<bool>();
    final timer = Timer(deadline, () {
      if (!guard.isCompleted) guard.complete(false);
    });
    final finishedInTime = await Future.any<bool>([stepsDone, guard.future]);
    timer.cancel();
    state.closed = true;

    if (!finishedInTime) {
      GjLog.warn('Bootstrap', 'deadline reached, remaining steps skipped');
    }
    if (!_progress.isLoaded) _progress.abandonLoad();

    final config =
        state.config ??
        LevelConfigService.fallbackToDefault(FetchStatus.skipped);
    final catalog = LevelCatalog.from(config.config);
    final analytics = _analyticsFor(state.firebase);
    final services = AppServices(
      config: config.config,
      catalog: catalog,
      progress: _progress,
      journey: JourneyController(repository: _progress, catalog: catalog),
      audio: AudioController(
        progress: _progress,
        player: _sfxPlayerFactory?.call(),
      ),
      analytics: analytics,
      session: SessionTracker(
        analytics: analytics,
        progress: _progress,
        clock: _clock,
      ),
    );
    // E2: nguồn cấu hình, gửi một lần sau bootstrap.
    unawaited(analytics.setConfigSource(config.config.source.label));
    final elapsed = _clock.now().difference(start);
    final firebase = state.firebase ?? FirebaseStatus.timeout;
    GjLog.info(
      'Bootstrap',
      'bootstrap done in ${elapsed.inMilliseconds}ms '
          '(firebase=${firebase.name}, fetch=${config.fetch.label})',
    );
    return BootstrapResult(
      services: services,
      firebase: firebase,
      fetch: config.fetch,
      elapsed: elapsed,
      deadlineHit: !finishedInTime,
    );
  }

  Future<void> _steps(DateTime start, _State state) async {
    try {
      final firebase = await _gateway.init();
      if (state.closed) return;
      state.firebase = firebase;

      if (firebase == FirebaseStatus.ok) {
        final budget = _fetchBudget(_clock.now().difference(start));
        state.config = await _loadConfig(budget);
      } else {
        state.config = LevelConfigService.fallbackToDefault(
          FetchStatus.skipped,
        );
      }
      if (state.closed) return;

      final remaining = deadline - _clock.now().difference(start);
      final loadBudget = remaining < progressTimeout
          ? remaining
          : progressTimeout;
      try {
        await _progress.load().timeout(
          loadBudget > Duration.zero ? loadBudget : Duration.zero,
        );
      } on TimeoutException catch (e) {
        GjLog.warn('Bootstrap', 'progress load timed out', e);
        _progress.abandonLoad();
      }
    } catch (e) {
      GjLog.error('Bootstrap', 'bootstrap step failed', e);
    }
  }

  /// Firebase Analytics chỉ khi Firebase đã khởi tạo xong; không thì Noop.
  AnalyticsService _analyticsFor(FirebaseStatus? firebase) {
    if (firebase != FirebaseStatus.ok) return const NoopAnalyticsService();
    try {
      return _analyticsFactory();
    } catch (e) {
      GjLog.error('Bootstrap', 'analytics unavailable', e);
      return const NoopAnalyticsService();
    }
  }

  static AnalyticsService _firebaseAnalytics() =>
      FirebaseAnalyticsService(FirebaseAnalyticsClient());

  Duration _fetchBudget(Duration elapsed) {
    final remaining = deadline - elapsed - localReserve;
    final budget = remaining < fetchMax ? remaining : fetchMax;
    return budget > Duration.zero ? budget : Duration.zero;
  }

  Future<LevelConfigLoadResult> _loadConfig(Duration budget) async {
    try {
      final service = LevelConfigService(client: _remoteConfigFactory());
      return await service.initialize(fetchBudget: budget);
    } catch (e) {
      GjLog.error('Bootstrap', 'remote config unavailable', e);
      return LevelConfigService.fallbackToDefault(FetchStatus.error);
    }
  }
}

class _State {
  FirebaseStatus? firebase;
  LevelConfigLoadResult? config;
  bool closed = false;
}
