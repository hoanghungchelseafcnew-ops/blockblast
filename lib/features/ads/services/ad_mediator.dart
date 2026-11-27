import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/log/gj_log.dart';
import '../models/ads_settings.dart';
import 'ad_counters.dart';
import 'ad_network_adapter.dart';
import 'consent_service.dart';

/// Kết quả của một lần bấm Start đối với interstitial (hợp đồng 2).
enum InterstitialOutcome {
  /// Chưa đủ N lần bấm Start.
  notDue,

  /// Quảng cáo đã hiện và đã đóng.
  shown,

  /// Đến lượt nhưng không hiện được; lượt này được bù ở lần sau (BR4.4).
  skipped,
}

/// Kết quả của một lần bấm WATCH AD TO TRY AGAIN (hợp đồng 2, ADR-007).
enum RewardOutcome {
  /// Người chơi xem đủ quảng cáo: được thưởng.
  earned,

  /// Người chơi đóng quảng cáo trước khi được thưởng: không thưởng (BR6.4).
  closedEarly,

  /// Không có quảng cáo để hiện: vẫn được thưởng (ADR-007).
  noAd,
}

/// Kết quả một lần yêu cầu banner (hợp đồng 2, `BannerResult`).
class BannerResult {
  /// Banner đã tải, kèm chiều cao trong [LoadedBanner.height].
  const BannerResult.shown(LoadedBanner this.banner);

  /// Không hiện: chưa đủ điều kiện, không mạng nào có banner, hoặc lỗi.
  const BannerResult.hidden() : banner = null;

  final LoadedBanner? banner;

  bool get isShown => banner != null;
}

/// Mặt tiếp xúc của quảng cáo với màn hình (contract-summary.md, hợp đồng 2).
///
/// Màn hình chỉ phụ thuộc interface này; khi quảng cáo tắt hay đang test thì
/// dùng [NoopAdsService], và màn hình mở ván chơi ngay không chờ.
abstract class AdsService {
  const AdsService();

  /// False với [NoopAdsService]: màn hình không cần chờ gì.
  bool get isActive;

  /// Gọi một lần sau khi vào Home lần đầu: đếm lần mở, hỏi đồng ý, khởi tạo
  /// các mạng và tải trước interstitial (BR3.4, BR4.6, BR5.1).
  Future<void> start();

  /// Gọi ngay sau mỗi lần bấm PLAY hoặc PLAY AGAIN. Chờ đến khi interstitial
  /// đóng nếu nó hiện; không bao giờ chờ quảng cáo tải (BR4.4).
  Future<InterstitialOutcome> interstitialIfDue();

  /// Tải trước quảng cáo reward để nút WATCH AD không phải chờ (u2,
  /// NFR2.9). Không bao giờ ném lỗi.
  Future<void> preloadReward();

  /// Hiện quảng cáo reward đã tải sẵn và chờ nó đóng. Chưa có quảng cáo thì
  /// trả [RewardOutcome.noAd] ngay, không chờ tải (ADR-007, NFR2.10).
  Future<RewardOutcome> reward();

  /// Ứng dụng quay lại trước màn hình từ nền (BR5.1, BR5.3).
  Future<void> onAppResumed();

  /// True khi đã đủ lần mở ứng dụng và đồng ý đã xử lý, tức là màn chơi nên
  /// yêu cầu banner (BR7.1).
  bool get bannerEligible;

  /// Báo mỗi khi một lần mở vừa được ghi xong hoặc đồng ý vừa xử lý xong,
  /// để vùng banner kiểm tra lại [bannerEligible] (BR7.2).
  Listenable get bannerChanges;

  /// Tải một banner rộng [width], thử mạng theo `ads_priority` (BR7.3).
  /// Không bao giờ ném lỗi (BR7.9).
  Future<BannerResult> banner(double width);

  /// Số lần mở ứng dụng đã đếm (BR5.1). Popup cập nhật dùng số này để hiện
  /// tối đa một lần mỗi lần mở (BR8.4).
  int get appOpenCount;

  /// True khi luồng khởi động quảng cáo (gồm hỏi đồng ý) đã xong, để popup
  /// cập nhật hiện sau hộp thoại đồng ý (BR8.5). Thay đổi được báo qua
  /// [bannerChanges].
  bool get startupSettled;

  /// Lần quay lại kế tiếp không được tính là một lần mở, vì nó do hộp thoại
  /// hệ thống hay bảng chia sẻ gây ra (BR5.3).
  void suppressNextResume();
}

/// Không có quảng cáo: dùng trong test và khi chưa dựng được quảng cáo.
class NoopAdsService extends AdsService {
  const NoopAdsService();

  @override
  bool get isActive => false;

  @override
  Future<void> start() async {}

  @override
  Future<InterstitialOutcome> interstitialIfDue() async =>
      InterstitialOutcome.notDue;

  @override
  Future<void> preloadReward() async {}

  @override
  Future<RewardOutcome> reward() async => RewardOutcome.noAd;

  @override
  Future<void> onAppResumed() async {}

  @override
  void suppressNextResume() {}

  @override
  bool get bannerEligible => false;

  @override
  Listenable get bannerChanges => const _SilentListenable();

  @override
  Future<BannerResult> banner(double width) async =>
      const BannerResult.hidden();

  @override
  int get appOpenCount => 0;

  @override
  bool get startupSettled => true;
}

/// `Listenable` không bao giờ báo gì, cho [NoopAdsService].
class _SilentListenable implements Listenable {
  const _SilentListenable();

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

class _Signal extends ChangeNotifier {
  void fire() => notifyListeners();
}

/// Quyết định có hiện quảng cáo không và chọn mạng theo `ads_priority`
/// (components.md, ADR-001). Không bao giờ ném lỗi ra ngoài (NFR2.1).
class AdMediator extends AdsService {
  AdMediator({
    required AdsSettings settings,
    required AdCounters counters,
    required ConsentService consent,
    required List<AdNetworkAdapter> adapters,
    this.perNetworkTimeout = const Duration(seconds: 5),
  }) : _settings = settings,
       _counters = counters,
       _consent = consent,
       _adapters = <AdNetwork, AdNetworkAdapter>{
         for (final adapter in adapters) adapter.network: adapter,
       };

  static const String _log = 'Ads';

  final AdsSettings _settings;
  final AdCounters _counters;
  final ConsentService _consent;
  final Map<AdNetwork, AdNetworkAdapter> _adapters;

  /// Thời hạn chờ cho mỗi mạng (BR2.5).
  final Duration perNetworkTimeout;

  Future<void>? _started;
  bool _networksReady = false;
  Future<void>? _preloading;
  bool _suppressNextResume = false;

  /// Mạng đang giữ interstitial đã tải (entities.md `InterstitialSlot`).
  AdNetwork? _readyNetwork;

  /// Mạng đang giữ quảng cáo reward đã tải.
  AdNetwork? _rewardNetwork;
  Future<void>? _rewardPreloading;

  final _Signal _bannerChanges = _Signal();
  bool _startupSettled = false;

  AdsSettings get settings => _settings;

  /// True khi có interstitial đã tải sẵn.
  bool get interstitialReady => _readyNetwork != null;

  /// True khi có quảng cáo reward đã tải sẵn.
  bool get rewardReady => _rewardNetwork != null;

  @override
  bool get isActive => true;

  @override
  Future<void> start() => _started ??= _start();

  Future<void> _start() async {
    try {
      await _counters.recordAppOpen();
      // Hộp thoại đồng ý làm ứng dụng mất focus; lần quay lại đó không phải
      // một lần mở (BR5.3).
      _suppressNextResume = true;
      await _consent.ensure();
      _suppressNextResume = false;
      await _initializeNetworks();
      await preloadInterstitial();
      if (_settings.rewardEnabled) unawaited(preloadReward());
    } catch (e) {
      GjLog.error(_log, 'starting ads failed', e);
    }
    _startupSettled = true;
    _bannerChanges.fire();
  }

  @override
  int get appOpenCount => _counters.appOpenCount;

  @override
  bool get startupSettled => _startupSettled;

  Future<void> _initializeNetworks() async {
    final personalized = _consent.personalizedAllowed;
    for (final network in _settings.adsPriority) {
      final adapter = _adapters[network];
      if (adapter == null) continue;
      try {
        await adapter.initialize(personalized: personalized);
      } catch (e) {
        GjLog.warn(_log, '${network.key} initialize failed', e);
      }
    }
    _networksReady = true;
  }

  /// Tải trước interstitial, thử từng mạng theo thứ tự (BR2.1, BR2.5,
  /// BR4.6). Chỉ một lần tải tại một thời điểm.
  Future<void> preloadInterstitial() {
    if (_readyNetwork != null) return Future.value();
    return _preloading ??= _preload().whenComplete(() => _preloading = null);
  }

  Future<void> _preload() async {
    if (!_consent.isProcessed || !_networksReady) return;
    final personalized = _consent.personalizedAllowed;
    for (final network in _settings.adsPriority) {
      final adapter = _adapters[network];
      if (adapter == null) continue;
      final result = await _loadWithTimeout(
        adapter,
        () => adapter.loadInterstitial(personalized: personalized),
      );
      if (result == AdLoadResult.ready) {
        _readyNetwork = network;
        GjLog.info(_log, 'interstitial ready from ${network.key}');
        return;
      }
    }
    GjLog.info(_log, 'no interstitial from any network');
  }

  Future<AdLoadResult> _loadWithTimeout(
    AdNetworkAdapter adapter,
    Future<AdLoadResult> Function() load,
  ) async {
    try {
      return await load().timeout(perNetworkTimeout);
    } on TimeoutException {
      GjLog.info(_log, '${adapter.network.key} timed out');
      return AdLoadResult.noFill;
    } catch (e) {
      GjLog.warn(_log, '${adapter.network.key} load failed', e);
      return AdLoadResult.error;
    }
  }

  @override
  Future<InterstitialOutcome> interstitialIfDue() async {
    try {
      await _counters.recordStart();
      final every = _settings.interstitialEveryNStarts;
      final due =
          _counters.startCount % every == 0 || _counters.interstitialCarriedDue;
      if (!due) {
        // Lần tải trước thất bại thì thử lại ở lần bấm Start này.
        unawaited(preloadInterstitial());
        return InterstitialOutcome.notDue;
      }

      final network = _readyNetwork;
      if (!_consent.isProcessed || network == null) {
        await _counters.setInterstitialCarriedDue(true);
        unawaited(preloadInterstitial());
        GjLog.info(_log, 'interstitial due but not ready, carried over');
        return InterstitialOutcome.skipped;
      }

      _readyNetwork = null;
      _suppressNextResume = true;
      final shown = await _show(network);
      _suppressNextResume = false;
      await _counters.setInterstitialCarriedDue(!shown);
      unawaited(preloadInterstitial());
      return shown ? InterstitialOutcome.shown : InterstitialOutcome.skipped;
    } catch (e) {
      GjLog.error(_log, 'interstitial step failed', e);
      return InterstitialOutcome.skipped;
    }
  }

  Future<bool> _show(AdNetwork network) async {
    final adapter = _adapters[network];
    if (adapter == null) return false;
    try {
      return await adapter.showInterstitial();
    } catch (e) {
      GjLog.warn(_log, '${network.key} show failed', e);
      return false;
    }
  }

  @override
  Future<void> preloadReward() {
    if (_rewardNetwork != null || !_settings.rewardEnabled) {
      return Future.value();
    }
    return _rewardPreloading ??= _preloadReward().whenComplete(
      () => _rewardPreloading = null,
    );
  }

  /// Tải quảng cáo reward, thử từng mạng theo `ads_priority`, mỗi mạng tối
  /// đa [perNetworkTimeout] (BR2.1, BR2.5). Chưa xử lý đồng ý thì không tải
  /// (BR3.1).
  Future<void> _preloadReward() async {
    try {
      if (!_consent.isProcessed || !_networksReady) return;
      final personalized = _consent.personalizedAllowed;
      for (final network in _settings.adsPriority) {
        final adapter = _adapters[network];
        if (adapter == null) continue;
        final result = await _loadWithTimeout(
          adapter,
          () => adapter.loadRewarded(personalized: personalized),
        );
        if (result == AdLoadResult.ready) {
          _rewardNetwork = network;
          GjLog.info(_log, 'rewarded ready from ${network.key}');
          return;
        }
      }
      GjLog.info(_log, 'no rewarded ad from any network');
    } catch (e) {
      GjLog.warn(_log, 'preloading rewarded failed', e);
    }
  }

  @override
  Future<RewardOutcome> reward() async {
    final network = _rewardNetwork;
    final adapter = network == null ? null : _adapters[network];
    if (!_consent.isProcessed || adapter == null) {
      // ADR-007: không có quảng cáo thì vẫn thưởng, không chờ tải.
      unawaited(preloadReward());
      GjLog.info(_log, 'rewarded not ready, rewarding without an ad');
      return RewardOutcome.noAd;
    }
    _rewardNetwork = null;
    _suppressNextResume = true;
    RewardShowResult shown;
    try {
      shown = await adapter.showRewarded();
    } catch (e) {
      GjLog.warn(_log, '${adapter.network.key} rewarded show failed', e);
      shown = RewardShowResult.failed;
    }
    _suppressNextResume = false;
    unawaited(preloadReward());
    switch (shown) {
      case RewardShowResult.earned:
        return RewardOutcome.earned;
      case RewardShowResult.closedEarly:
        return RewardOutcome.closedEarly;
      case RewardShowResult.failed:
        return RewardOutcome.noAd;
    }
  }

  @override
  Future<void> onAppResumed() async {
    if (_suppressNextResume) {
      _suppressNextResume = false;
      return;
    }
    try {
      await _counters.recordAppOpen();
    } catch (e) {
      GjLog.warn(_log, 'counting app open failed', e);
    }
    _bannerChanges.fire();
  }

  @override
  bool get bannerEligible =>
      _consent.isProcessed &&
      _networksReady &&
      _counters.appOpenCount >= _settings.bannerStartVisit;

  @override
  Listenable get bannerChanges => _bannerChanges;

  @override
  Future<BannerResult> banner(double width) async {
    try {
      if (!bannerEligible) return const BannerResult.hidden();
      final personalized = _consent.personalizedAllowed;
      for (final network in _settings.adsPriority) {
        final adapter = _adapters[network];
        if (adapter == null) continue;
        final loaded = await _loadBannerWithTimeout(
          adapter,
          width,
          personalized,
        );
        if (loaded != null) {
          GjLog.info(_log, 'banner shown from ${network.key}');
          return BannerResult.shown(loaded);
        }
      }
      GjLog.info(_log, 'no banner from any network');
    } catch (e) {
      GjLog.warn(_log, 'banner failed', e);
    }
    return const BannerResult.hidden();
  }

  /// Banner tải xong sau thời hạn thì bị giải phóng ngay (NFR2.21).
  Future<LoadedBanner?> _loadBannerWithTimeout(
    AdNetworkAdapter adapter,
    double width,
    bool personalized,
  ) async {
    Future<LoadedBanner?> load;
    try {
      load = adapter.loadBanner(width: width, personalized: personalized);
    } catch (e) {
      GjLog.warn(_log, '${adapter.network.key} banner failed', e);
      return null;
    }
    try {
      return await load.timeout(perNetworkTimeout);
    } on TimeoutException {
      GjLog.info(_log, '${adapter.network.key} banner timed out');
      unawaited(
        load.then<void>((late) => late?.dispose()).catchError((Object _) {}),
      );
      return null;
    } catch (e) {
      GjLog.warn(_log, '${adapter.network.key} banner failed', e);
      return null;
    }
  }

  @override
  void suppressNextResume() => _suppressNextResume = true;
}
