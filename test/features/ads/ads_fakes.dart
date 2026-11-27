import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:block_blast/features/ads/models/ads_settings.dart';
import 'package:block_blast/features/ads/services/ad_mediator.dart';
import 'package:block_blast/features/ads/services/ad_network_adapter.dart';
import 'package:block_blast/features/ads/services/consent_service.dart';

/// Cổng đồng ý giả: trả [result], ném [error] hoặc chờ [pending].
class FakeConsentGateway implements ConsentGateway {
  FakeConsentGateway({
    this.result = const ConsentResult(
      state: ConsentState.notApplicable,
      personalizedAllowed: true,
    ),
    this.error,
  });

  ConsentResult result;
  Object? error;
  Completer<ConsentResult>? pending;
  int calls = 0;

  @override
  Future<ConsentResult> gather() async {
    calls++;
    final waiting = pending;
    if (waiting != null) return waiting.future;
    final failure = error;
    if (failure != null) throw failure;
    return result;
  }
}

/// Mạng giả: trả lần lượt các kết quả tải đã đặt, có thể treo hoặc ném lỗi.
class FakeAdNetwork implements AdNetworkAdapter {
  FakeAdNetwork(this.network, {List<AdLoadResult>? loads})
    : loads = List<AdLoadResult>.of(loads ?? const [AdLoadResult.ready]);

  @override
  final AdNetwork network;

  /// Kết quả của các lần tải kế tiếp; hết danh sách thì lặp lại phần tử cuối.
  final List<AdLoadResult> loads;

  bool hangLoad = false;
  Object? loadError;
  Object? initError;
  bool showResult = true;

  int initCalls = 0;
  int loadCalls = 0;
  int showCalls = 0;
  bool? lastPersonalized;

  @override
  Future<void> initialize({required bool personalized}) async {
    initCalls++;
    lastPersonalized = personalized;
    final error = initError;
    if (error != null) throw error;
  }

  @override
  Future<AdLoadResult> loadInterstitial({required bool personalized}) async {
    loadCalls++;
    lastPersonalized = personalized;
    if (hangLoad) return Completer<AdLoadResult>().future;
    final error = loadError;
    if (error != null) throw error;
    if (loads.length > 1) return loads.removeAt(0);
    return loads.single;
  }

  @override
  Future<bool> showInterstitial() async {
    showCalls++;
    return showResult;
  }

  /// Kết quả của các lần tải reward kế tiếp; hết danh sách thì lặp lại phần
  /// tử cuối.
  List<AdLoadResult> rewardLoads = [AdLoadResult.ready];
  bool hangRewardLoad = false;
  RewardShowResult rewardShowResult = RewardShowResult.earned;
  Object? rewardShowError;

  int rewardLoadCalls = 0;
  int rewardShowCalls = 0;

  @override
  Future<AdLoadResult> loadRewarded({required bool personalized}) async {
    rewardLoadCalls++;
    lastPersonalized = personalized;
    if (hangRewardLoad) return Completer<AdLoadResult>().future;
    if (rewardLoads.length > 1) return rewardLoads.removeAt(0);
    return rewardLoads.single;
  }

  @override
  Future<RewardShowResult> showRewarded() async {
    rewardShowCalls++;
    final error = rewardShowError;
    if (error != null) throw error;
    return rewardShowResult;
  }

  /// Chiều cao banner trả về; null nghĩa là mạng không có banner.
  double? bannerHeight = 50;
  bool hangBanner = false;
  Object? bannerError;
  int bannerLoadCalls = 0;
  final List<FakeLoadedBanner> banners = <FakeLoadedBanner>[];

  /// Khi khác null, lần tải banner chờ completer này rồi mới trả banner.
  Completer<void>? holdBanner;

  @override
  Future<LoadedBanner?> loadBanner({
    required double width,
    required bool personalized,
  }) async {
    bannerLoadCalls++;
    lastPersonalized = personalized;
    if (hangBanner) return Completer<LoadedBanner?>().future;
    final error = bannerError;
    if (error != null) throw error;
    final hold = holdBanner;
    if (hold != null) await hold.future;
    final height = bannerHeight;
    if (height == null) return null;
    final banner = FakeLoadedBanner(height, label: network.key);
    banners.add(banner);
    return banner;
  }
}

/// Banner giả: hiện một ô có key `fake-banner-<label>` và đếm số lần giải
/// phóng.
class FakeLoadedBanner implements LoadedBanner {
  FakeLoadedBanner(this.height, {this.label = 'fake'});

  @override
  final double height;
  final String label;
  int disposeCalls = 0;

  @override
  Widget build() => SizedBox(key: Key('fake-banner-$label'), height: height);

  @override
  void dispose() => disposeCalls++;
}

/// [AdsService] giả cho test màn hình: ghi lại các lần gọi.
class FakeAdsService extends AdsService {
  FakeAdsService({
    this.outcome = InterstitialOutcome.shown,
    this.rewardOutcome = RewardOutcome.earned,
  });

  InterstitialOutcome outcome;
  RewardOutcome rewardOutcome;

  /// Khi khác null, `reward` chờ completer này (quảng cáo đang hiện).
  Completer<void>? holdReward;

  int preloadRewardCalls = 0;
  int rewardCalls = 0;

  /// Banner (u3-banner): đủ điều kiện chưa và kết quả của `banner`.
  bool eligible = false;
  double? bannerResultHeight = 50;

  /// Khi khác null, `banner` chờ completer này.
  Completer<void>? holdBanner;
  int bannerCalls = 0;
  final List<FakeLoadedBanner> banners = <FakeLoadedBanner>[];
  final _FakeSignal _bannerSignal = _FakeSignal();

  /// Giả lập một lần mở vừa được ghi xong.
  void notifyBannerChange() => _bannerSignal.fire();

  /// Khi khác null, `interstitialIfDue` chờ completer này.
  Completer<void>? holdInterstitial;

  int startCalls = 0;
  int interstitialCalls = 0;
  int resumeCalls = 0;
  int suppressCalls = 0;

  @override
  bool get isActive => true;

  @override
  Future<void> start() async => startCalls++;

  @override
  Future<InterstitialOutcome> interstitialIfDue() async {
    interstitialCalls++;
    final hold = holdInterstitial;
    if (hold != null) await hold.future;
    return outcome;
  }

  @override
  Future<void> preloadReward() async => preloadRewardCalls++;

  @override
  Future<RewardOutcome> reward() async {
    rewardCalls++;
    final hold = holdReward;
    if (hold != null) await hold.future;
    return rewardOutcome;
  }

  @override
  bool get bannerEligible => eligible;

  /// Popup cập nhật (u4-update-and-share).
  int opens = 1;
  bool settled = true;

  @override
  int get appOpenCount => opens;

  @override
  bool get startupSettled => settled;

  @override
  Listenable get bannerChanges => _bannerSignal;

  @override
  Future<BannerResult> banner(double width) async {
    bannerCalls++;
    final hold = holdBanner;
    if (hold != null) await hold.future;
    final height = bannerResultHeight;
    if (height == null) return const BannerResult.hidden();
    final b = FakeLoadedBanner(height);
    banners.add(b);
    return BannerResult.shown(b);
  }

  @override
  Future<void> onAppResumed() async => resumeCalls++;

  @override
  void suppressNextResume() => suppressCalls++;
}

class _FakeSignal extends ChangeNotifier {
  void fire() => notifyListeners();
}
