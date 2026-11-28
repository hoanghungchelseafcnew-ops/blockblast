import 'dart:async';

import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/widgets.dart';

import '../../../core/log/gj_log.dart';
import '../models/ads_settings.dart';
import 'ad_network_adapter.dart';
import 'ad_unit_ids.dart';

/// Adapter AppLovin MAX trên `applovin_max` (ADR-001). `appId` là SDK key,
/// `interstitialId` là ad unit ID.
///
/// AppLovin báo kết quả qua một listener dùng chung, nên adapter giữ một
/// completer cho lần tải và một cho lần hiện đang chờ.
class ApplovinAdapter implements AdNetworkAdapter {
  ApplovinAdapter({AdNetworkIds? ids}) : _ids = ids ?? AdUnitIds.applovin;

  static const String _log = 'Ads.AppLovin';

  final AdNetworkIds _ids;
  bool _initialized = false;
  bool _loaded = false;
  Completer<AdLoadResult>? _pendingLoad;
  Completer<bool>? _pendingShow;
  bool _rewardLoaded = false;
  bool _rewardEarned = false;
  Completer<AdLoadResult>? _pendingRewardLoad;
  Completer<RewardShowResult>? _pendingRewardShow;
  Completer<bool>? _pendingBannerLoad;

  @override
  AdNetwork get network => AdNetwork.applovin;

  @override
  Future<void> initialize({required bool personalized}) async {
    if (!_ids.isConfigured &&
        !_ids.rewardedConfigured &&
        !_ids.bannerConfigured) {
      return;
    }
    try {
      AppLovinMAX.setHasUserConsent(personalized);
      AppLovinMAX.setInterstitialListener(
        InterstitialListener(
          onAdLoadedCallback: (ad) {
            _loaded = true;
            _completeLoad(AdLoadResult.ready);
          },
          onAdLoadFailedCallback: (adUnitId, error) {
            GjLog.info(_log, 'interstitial not filled');
            _completeLoad(AdLoadResult.noFill);
          },
          onAdDisplayedCallback: (ad) {},
          onAdDisplayFailedCallback: (ad, error) {
            GjLog.warn(_log, 'interstitial failed to show');
            _completeShow(false);
          },
          onAdClickedCallback: (ad) {},
          onAdHiddenCallback: (ad) => _completeShow(true),
        ),
      );
      AppLovinMAX.setRewardedAdListener(
        RewardedAdListener(
          onAdLoadedCallback: (ad) {
            _rewardLoaded = true;
            _completeRewardLoad(AdLoadResult.ready);
          },
          onAdLoadFailedCallback: (adUnitId, error) {
            GjLog.info(_log, 'rewarded not filled');
            _completeRewardLoad(AdLoadResult.noFill);
          },
          onAdDisplayedCallback: (ad) {},
          onAdDisplayFailedCallback: (ad, error) {
            GjLog.warn(_log, 'rewarded failed to show');
            _completeRewardShow(RewardShowResult.failed);
          },
          onAdClickedCallback: (ad) {},
          onAdReceivedRewardCallback: (ad, reward) => _rewardEarned = true,
          onAdHiddenCallback: (ad) => _completeRewardShow(
            _rewardEarned
                ? RewardShowResult.earned
                : RewardShowResult.closedEarly,
          ),
        ),
      );
      await AppLovinMAX.initialize(_ids.appId);
      _initialized = true;
    } catch (e) {
      GjLog.warn(_log, 'initialize failed', e);
    }
  }

  void _completeLoad(AdLoadResult result) {
    final pending = _pendingLoad;
    _pendingLoad = null;
    if (pending != null && !pending.isCompleted) pending.complete(result);
  }

  void _completeShow(bool shown) {
    final pending = _pendingShow;
    _pendingShow = null;
    if (pending != null && !pending.isCompleted) pending.complete(shown);
  }

  void _completeRewardLoad(AdLoadResult result) {
    final pending = _pendingRewardLoad;
    _pendingRewardLoad = null;
    if (pending != null && !pending.isCompleted) pending.complete(result);
  }

  void _completeRewardShow(RewardShowResult result) {
    final pending = _pendingRewardShow;
    _pendingRewardShow = null;
    if (pending != null && !pending.isCompleted) pending.complete(result);
  }

  @override
  Future<AdLoadResult> loadRewarded({required bool personalized}) {
    if (!_ids.rewardedConfigured || !_initialized) {
      return Future.value(AdLoadResult.noFill);
    }
    _completeRewardLoad(AdLoadResult.noFill);
    final result = Completer<AdLoadResult>();
    _pendingRewardLoad = result;
    try {
      AppLovinMAX.loadRewardedAd(_ids.rewardedId);
    } catch (e) {
      GjLog.warn(_log, 'rewarded load failed', e);
      _completeRewardLoad(AdLoadResult.error);
    }
    return result.future;
  }

  @override
  Future<RewardShowResult> showRewarded() {
    if (!_rewardLoaded) return Future.value(RewardShowResult.failed);
    _rewardLoaded = false;
    _rewardEarned = false;
    final closed = Completer<RewardShowResult>();
    _pendingRewardShow = closed;
    try {
      AppLovinMAX.showRewardedAd(_ids.rewardedId);
    } catch (e) {
      GjLog.warn(_log, 'rewarded show failed', e);
      _completeRewardShow(RewardShowResult.failed);
    }
    return closed.future;
  }

  @override
  Future<AdLoadResult> loadInterstitial({required bool personalized}) {
    if (!_ids.isConfigured || !_initialized) {
      return Future.value(AdLoadResult.noFill);
    }
    _completeLoad(AdLoadResult.noFill);
    final result = Completer<AdLoadResult>();
    _pendingLoad = result;
    try {
      AppLovinMAX.loadInterstitial(_ids.interstitialId);
    } catch (e) {
      GjLog.warn(_log, 'interstitial load failed', e);
      _completeLoad(AdLoadResult.error);
    }
    return result.future;
  }

  @override
  Future<bool> showInterstitial() {
    if (!_loaded) return Future.value(false);
    _loaded = false;
    final closed = Completer<bool>();
    _pendingShow = closed;
    try {
      AppLovinMAX.showInterstitial(_ids.interstitialId);
    } catch (e) {
      GjLog.warn(_log, 'interstitial show failed', e);
      _completeShow(false);
    }
    return closed.future;
  }

  /// Tải trước một `MaxAdView` banner cỡ chuẩn 320 x 50 (yêu cầu thay đổi
  /// CR-1). AppLovin báo kết quả tải trước qua một listener dùng chung, nên
  /// mỗi lần chỉ một lần tải.
  @override
  Future<LoadedBanner?> loadBanner({
    required double width,
    required bool personalized,
  }) async {
    if (!_ids.bannerConfigured || !_initialized) return null;
    _completeBannerLoad(false);
    final loaded = Completer<bool>();
    _pendingBannerLoad = loaded;
    AdViewId? adViewId;
    try {
      AppLovinMAX.setWidgetAdViewAdListener(
        WidgetAdViewAdListener(
          onAdLoadedCallback: (ad) => _completeBannerLoad(true),
          onAdLoadFailedCallback: (adUnitId, error) {
            GjLog.info(_log, 'banner not filled');
            _completeBannerLoad(false);
          },
        ),
      );
      adViewId = await AppLovinMAX.preloadWidgetAdView(
        _ids.bannerId,
        AdFormat.banner,
        isAdaptive: false,
      );
      if (adViewId == null || !await loaded.future) {
        if (adViewId != null) _destroyBanner(adViewId);
        return null;
      }
      return _ApplovinBanner(_ids.bannerId, adViewId);
    } catch (e) {
      GjLog.warn(_log, 'banner load failed', e);
      _completeBannerLoad(false);
      if (adViewId != null) _destroyBanner(adViewId);
      return null;
    }
  }

  void _completeBannerLoad(bool loaded) {
    final pending = _pendingBannerLoad;
    _pendingBannerLoad = null;
    if (pending != null && !pending.isCompleted) pending.complete(loaded);
  }

  static void _destroyBanner(AdViewId id) {
    AppLovinMAX.destroyWidgetAdView(
      id,
    ).catchError((Object e) => GjLog.warn(_log, 'banner destroy failed', e));
  }
}

class _ApplovinBanner implements LoadedBanner {
  _ApplovinBanner(this._adUnitId, this._adViewId);

  static const double _width = 320;

  final String _adUnitId;
  final AdViewId _adViewId;

  @override
  double get height => 50;

  @override
  Widget build() => MaxAdView(
    adUnitId: _adUnitId,
    adFormat: AdFormat.banner,
    adViewId: _adViewId,
    isAdaptiveBannerEnabled: false,
    width: _width,
    height: height,
  );

  @override
  void dispose() => ApplovinAdapter._destroyBanner(_adViewId);
}
