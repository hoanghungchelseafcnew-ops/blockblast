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
import '../../ads/models/ads_settings.dart';
import '../../ads/services/ad_mediator.dart';
import '../../ads/services/ads_config.dart';
import '../../ads/services/pending_loss_store.dart';
import '../../update/services/app_update_checker.dart';
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
    this.ads = const NoopAdsService(),
    this.adsSettings = AdsSettings.defaults,
    this.pendingLoss,
    this.updates,
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

  /// Quảng cáo (u1-ads-core). Mặc định không có quảng cáo.
  final AdsService ads;

  /// Cấu hình quảng cáo và phiên bản đã kiểm tra (BR1.1 đến BR1.3).
  final AdsSettings adsSettings;

  /// Dấu lần thua chưa ghi nhận (u2-reward-ads, BR6.7). Null thì không lưu.
  final PendingLossStore? pendingLoss;

  /// Kiểm tra bản mới cho popup trên Home (u4-update-and-share). Null thì
  /// không kiểm tra.
  final AppUpdateChecker? updates;
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
    AdsService Function(AdsSettings settings)? adsFactory,
    PendingLossStore? pendingLoss,
    AppUpdateChecker Function(AdsSettings settings)? updateCheckerFactory,
    this.deadline = const Duration(milliseconds: 3500),
    this.fetchMax = const Duration(seconds: 2),
    this.localReserve = const Duration(milliseconds: 500),
    this.progressTimeout = const Duration(milliseconds: 500),
  }) : _gateway = gateway,
       _remoteConfigFactory = remoteConfigFactory,
       _progress = progress,
       _clock = clock,
       _sfxPlayerFactory = sfxPlayerFactory,
       _analyticsFactory = analyticsFactory ?? _firebaseAnalytics,
       _adsFactory = adsFactory,
       _pendingLoss = pendingLoss,
       _updateCheckerFactory = updateCheckerFactory;

  final FirebaseGateway _gateway;
  final RemoteConfigClient Function() _remoteConfigFactory;
  final ProgressRepository _progress;
  final Clock _clock;
  final SfxPlayer Function()? _sfxPlayerFactory;
  final AnalyticsService Function() _analyticsFactory;
  final AdsService Function(AdsSettings settings)? _adsFactory;
  final PendingLossStore? _pendingLoss;
  final AppUpdateChecker Function(AdsSettings settings)? _updateCheckerFactory;

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
    // Chỉ đọc cấu hình đã activate, không fetch thêm: không tốn thêm thời
    // gian của hạn chót (NFR1.1).
    final adsSettings = AdsConfig.read(state.client);
    final journey = JourneyController(repository: _progress, catalog: catalog);
    await _settlePendingLoss(journey, catalog, start);
    final services = AppServices(
      config: config.config,
      catalog: catalog,
      progress: _progress,
      journey: journey,
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
      ads: _adsFor(adsSettings),
      adsSettings: adsSettings,
      pendingLoss: _pendingLoss,
      updates: _updatesFor(adsSettings),
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
        state.config = await _loadConfig(budget, state);
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

  /// App bị tắt ở lớp phủ Game Over khi lần thua còn hoãn: ghi nhận thua
  /// trước khi vào Home (BR6.7), trong thời gian còn lại của hạn chót. Lỗi
  /// hay hết giờ không chặn khởi động; dấu còn lại cho lần mở sau.
  Future<void> _settlePendingLoss(
    JourneyController journey,
    LevelCatalog catalog,
    DateTime start,
  ) async {
    final store = _pendingLoss;
    if (store == null || !_progress.isLoaded) return;
    // Trong phần còn lại của hạn chót, tối đa [progressTimeout]. Hạn chót đã
    // hết thì vẫn cho một khoảng ngắn: đọc kho cục bộ rất nhanh.
    const floor = Duration(milliseconds: 100);
    final remaining = deadline - _clock.now().difference(start);
    final budget = remaining > progressTimeout
        ? progressTimeout
        : (remaining < floor ? floor : remaining);
    try {
      await () async {
        final pending = await store.read();
        if (pending == null) return;
        final level = catalog.byIndexOr(
          pending.levelIndex,
          journey.currentLevel,
        );
        GjLog.info(
          'Bootstrap',
          'recording pending loss: levelId=${level.levelIndex}',
        );
        await journey.onLevelLost(level, pending.score);
        await store.clear();
      }().timeout(budget);
    } catch (e) {
      GjLog.warn('Bootstrap', 'pending loss not recorded', e);
    }
  }

  /// Dựng kiểm tra phiên bản; lỗi thì không có popup, game vẫn chạy.
  AppUpdateChecker? _updatesFor(AdsSettings settings) {
    final factory = _updateCheckerFactory;
    if (factory == null) return null;
    try {
      return factory(settings);
    } catch (e) {
      GjLog.error('Bootstrap', 'update check unavailable', e);
      return null;
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

  /// Dựng quảng cáo; lỗi thì không có quảng cáo, game vẫn chạy (NFR2.1).
  /// Khởi tạo SDK không chạy ở đây mà ở `AdsService.start()` từ Home.
  AdsService _adsFor(AdsSettings settings) {
    final factory = _adsFactory;
    if (factory == null) return const NoopAdsService();
    try {
      return factory(settings);
    } catch (e) {
      GjLog.error('Bootstrap', 'ads unavailable', e);
      return const NoopAdsService();
    }
  }

  static AnalyticsService _firebaseAnalytics() =>
      FirebaseAnalyticsService(FirebaseAnalyticsClient());

  Duration _fetchBudget(Duration elapsed) {
    final remaining = deadline - elapsed - localReserve;
    final budget = remaining < fetchMax ? remaining : fetchMax;
    return budget > Duration.zero ? budget : Duration.zero;
  }

  Future<LevelConfigLoadResult> _loadConfig(
    Duration budget,
    _State state,
  ) async {
    try {
      final client = _remoteConfigFactory();
      state.client = client;
      final service = LevelConfigService(client: client);
      return await service.initialize(fetchBudget: budget);
    } catch (e) {
      GjLog.error('Bootstrap', 'remote config unavailable', e);
      return LevelConfigService.fallbackToDefault(FetchStatus.error);
    }
  }
}

class _State {
  FirebaseStatus? firebase;
  RemoteConfigClient? client;
  LevelConfigLoadResult? config;
  bool closed = false;
}
