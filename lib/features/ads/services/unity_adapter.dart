import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import '../../../core/log/gj_log.dart';
import '../models/ads_settings.dart';
import 'ad_network_adapter.dart';
import 'ad_unit_ids.dart';

/// Adapter Unity Ads trên `unity_ads_plugin` (ADR-001). `appId` là game ID,
/// `interstitialId` là placement ID.
class UnityAdapter implements AdNetworkAdapter {
  UnityAdapter({AdNetworkIds? ids}) : _ids = ids ?? AdUnitIds.unity;

  static const String _log = 'Ads.Unity';

  final AdNetworkIds _ids;
  bool _initialized = false;
  bool _loaded = false;
  bool _rewardLoaded = false;

  @override
  AdNetwork get network => AdNetwork.unity;

  @override
  Future<void> initialize({required bool personalized}) async {
    if (!_ids.isConfigured && !_ids.rewardedConfigured) return;
    try {
      await UnityAds.setPrivacyConsent(PrivacyConsentType.gdpr, personalized);
      final done = Completer<void>();
      await UnityAds.init(
        gameId: _ids.appId,
        testMode: kDebugMode,
        onComplete: () {
          _initialized = true;
          if (!done.isCompleted) done.complete();
        },
        onFailed: (error, message) {
          GjLog.warn(_log, 'initialize failed');
          if (!done.isCompleted) done.complete();
        },
      );
      await done.future;
    } catch (e) {
      GjLog.warn(_log, 'initialize failed', e);
    }
  }

  @override
  Future<AdLoadResult> loadInterstitial({required bool personalized}) {
    if (!_ids.isConfigured || !_initialized) {
      return Future.value(AdLoadResult.noFill);
    }
    final result = Completer<AdLoadResult>();
    try {
      UnityAds.load(
        placementId: _ids.interstitialId,
        onComplete: (placementId) {
          _loaded = true;
          if (!result.isCompleted) result.complete(AdLoadResult.ready);
        },
        onFailed: (placementId, error, message) {
          GjLog.info(_log, 'interstitial not filled');
          if (!result.isCompleted) result.complete(AdLoadResult.noFill);
        },
      );
    } catch (e) {
      GjLog.warn(_log, 'interstitial load failed', e);
      if (!result.isCompleted) result.complete(AdLoadResult.error);
    }
    return result.future;
  }

  @override
  Future<bool> showInterstitial() {
    if (!_loaded) return Future.value(false);
    _loaded = false;
    final closed = Completer<bool>();
    try {
      UnityAds.showVideoAd(
        placementId: _ids.interstitialId,
        onComplete: (placementId) {
          if (!closed.isCompleted) closed.complete(true);
        },
        onSkipped: (placementId) {
          if (!closed.isCompleted) closed.complete(true);
        },
        onFailed: (placementId, error, message) {
          GjLog.warn(_log, 'interstitial failed to show');
          if (!closed.isCompleted) closed.complete(false);
        },
      );
    } catch (e) {
      GjLog.warn(_log, 'interstitial show failed', e);
      if (!closed.isCompleted) closed.complete(false);
    }
    return closed.future;
  }

  @override
  Future<AdLoadResult> loadRewarded({required bool personalized}) {
    if (!_ids.rewardedConfigured || !_initialized) {
      return Future.value(AdLoadResult.noFill);
    }
    final result = Completer<AdLoadResult>();
    try {
      UnityAds.load(
        placementId: _ids.rewardedId,
        onComplete: (placementId) {
          _rewardLoaded = true;
          if (!result.isCompleted) result.complete(AdLoadResult.ready);
        },
        onFailed: (placementId, error, message) {
          GjLog.info(_log, 'rewarded not filled');
          if (!result.isCompleted) result.complete(AdLoadResult.noFill);
        },
      );
    } catch (e) {
      GjLog.warn(_log, 'rewarded load failed', e);
      if (!result.isCompleted) result.complete(AdLoadResult.error);
    }
    return result.future;
  }

  /// Unity báo `onComplete` khi xem đủ (được thưởng) và `onSkipped` khi
  /// người chơi bỏ qua (đóng sớm, BR6.4).
  @override
  Future<RewardShowResult> showRewarded() {
    if (!_rewardLoaded) return Future.value(RewardShowResult.failed);
    _rewardLoaded = false;
    final closed = Completer<RewardShowResult>();
    try {
      UnityAds.showVideoAd(
        placementId: _ids.rewardedId,
        onComplete: (placementId) {
          if (!closed.isCompleted) closed.complete(RewardShowResult.earned);
        },
        onSkipped: (placementId) {
          if (!closed.isCompleted) {
            closed.complete(RewardShowResult.closedEarly);
          }
        },
        onFailed: (placementId, error, message) {
          GjLog.warn(_log, 'rewarded failed to show');
          if (!closed.isCompleted) closed.complete(RewardShowResult.failed);
        },
      );
    } catch (e) {
      GjLog.warn(_log, 'rewarded show failed', e);
      if (!closed.isCompleted) closed.complete(RewardShowResult.failed);
    }
    return closed.future;
  }

  /// Unity chỉ có banner cỡ cố định nên không dùng cho banner (Q2 của
  /// nfr-requirements của u3-banner).
  @override
  Future<LoadedBanner?> loadBanner({
    required double width,
    required bool personalized,
  }) async => null;
}
