import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/log/gj_log.dart';
import '../models/ads_settings.dart';
import 'ad_network_adapter.dart';
import 'ad_unit_ids.dart';

/// Adapter AdMob trên `google_mobile_ads` (ADR-001).
class AdmobAdapter implements AdNetworkAdapter {
  AdmobAdapter({AdNetworkIds? ids}) : _ids = ids ?? AdUnitIds.admob;

  static const String _log = 'Ads.AdMob';

  final AdNetworkIds _ids;
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;

  @override
  AdNetwork get network => AdNetwork.admob;

  @override
  Future<void> initialize({required bool personalized}) async {
    if (!_ids.isConfigured &&
        !_ids.rewardedConfigured &&
        !_ids.bannerConfigured) {
      return;
    }
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      GjLog.warn(_log, 'initialize failed', e);
    }
  }

  @override
  Future<AdLoadResult> loadInterstitial({required bool personalized}) async {
    if (!_ids.isConfigured) return AdLoadResult.noFill;
    final result = Completer<AdLoadResult>();
    try {
      await InterstitialAd.load(
        adUnitId: _ids.interstitialId,
        request: AdRequest(nonPersonalizedAds: !personalized),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitial?.dispose();
            _interstitial = ad;
            if (!result.isCompleted) result.complete(AdLoadResult.ready);
          },
          onAdFailedToLoad: (error) {
            GjLog.info(_log, 'interstitial not filled (code ${error.code})');
            if (!result.isCompleted) result.complete(AdLoadResult.noFill);
          },
        ),
      );
    } catch (e) {
      GjLog.warn(_log, 'interstitial load failed', e);
      if (!result.isCompleted) result.complete(AdLoadResult.error);
    }
    return result.future;
  }

  @override
  Future<bool> showInterstitial() {
    final ad = _interstitial;
    _interstitial = null;
    if (ad == null) return Future.value(false);
    final closed = Completer<bool>();
    try {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          if (!closed.isCompleted) closed.complete(true);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          GjLog.warn(_log, 'interstitial failed to show (code ${error.code})');
          ad.dispose();
          if (!closed.isCompleted) closed.complete(false);
        },
      );
      ad.show();
    } catch (e) {
      GjLog.warn(_log, 'interstitial show failed', e);
      ad.dispose();
      if (!closed.isCompleted) closed.complete(false);
    }
    return closed.future;
  }

  @override
  Future<AdLoadResult> loadRewarded({required bool personalized}) async {
    if (!_ids.rewardedConfigured) return AdLoadResult.noFill;
    final result = Completer<AdLoadResult>();
    try {
      await RewardedAd.load(
        adUnitId: _ids.rewardedId,
        request: AdRequest(nonPersonalizedAds: !personalized),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewarded?.dispose();
            _rewarded = ad;
            if (!result.isCompleted) result.complete(AdLoadResult.ready);
          },
          onAdFailedToLoad: (error) {
            GjLog.info(_log, 'rewarded not filled (code ${error.code})');
            if (!result.isCompleted) result.complete(AdLoadResult.noFill);
          },
        ),
      );
    } catch (e) {
      GjLog.warn(_log, 'rewarded load failed', e);
      if (!result.isCompleted) result.complete(AdLoadResult.error);
    }
    return result.future;
  }

  @override
  Future<RewardShowResult> showRewarded() {
    final ad = _rewarded;
    _rewarded = null;
    if (ad == null) return Future.value(RewardShowResult.failed);
    final closed = Completer<RewardShowResult>();
    var earned = false;
    try {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          if (!closed.isCompleted) {
            closed.complete(
              earned ? RewardShowResult.earned : RewardShowResult.closedEarly,
            );
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          GjLog.warn(_log, 'rewarded failed to show (code ${error.code})');
          ad.dispose();
          if (!closed.isCompleted) closed.complete(RewardShowResult.failed);
        },
      );
      ad.show(onUserEarnedReward: (ad, reward) => earned = true);
    } catch (e) {
      GjLog.warn(_log, 'rewarded show failed', e);
      ad.dispose();
      if (!closed.isCompleted) closed.complete(RewardShowResult.failed);
    }
    return closed.future;
  }

  @override
  Future<LoadedBanner?> loadBanner({
    required double width,
    required bool personalized,
  }) async {
    if (!_ids.bannerConfigured) return null;
    final result = Completer<LoadedBanner?>();
    try {
      final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
        width.truncate(),
      );
      if (size == null) {
        GjLog.info(_log, 'no adaptive banner size for width $width');
        return null;
      }
      final ad = BannerAd(
        adUnitId: _ids.bannerId,
        size: size,
        request: AdRequest(nonPersonalizedAds: !personalized),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (result.isCompleted) {
              ad.dispose();
              return;
            }
            result.complete(_AdmobBanner(ad as BannerAd, size.height));
          },
          onAdFailedToLoad: (ad, error) {
            GjLog.info(_log, 'banner not filled (code ${error.code})');
            ad.dispose();
            if (!result.isCompleted) result.complete(null);
          },
        ),
      );
      await ad.load();
    } catch (e) {
      GjLog.warn(_log, 'banner load failed', e);
      if (!result.isCompleted) result.complete(null);
    }
    return result.future;
  }
}

class _AdmobBanner implements LoadedBanner {
  _AdmobBanner(this._ad, int height) : height = height.toDouble();

  final BannerAd _ad;

  @override
  final double height;

  @override
  Widget build() => AdWidget(ad: _ad);

  @override
  void dispose() {
    try {
      _ad.dispose();
    } catch (e) {
      GjLog.warn('Ads.AdMob', 'banner dispose failed', e);
    }
  }
}
