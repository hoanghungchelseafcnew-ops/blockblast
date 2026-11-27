import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Định danh của từng mạng cho một nền tảng. Chuỗi rỗng nghĩa là chưa cấu
/// hình, và mạng đó được coi như không có quảng cáo.
class AdNetworkIds {
  const AdNetworkIds({
    this.appId = '',
    this.interstitialId = '',
    this.rewardedId = '',
    this.bannerId = '',
  });

  /// ID ứng dụng, game ID (Unity) hoặc SDK key (AppLovin).
  final String appId;
  final String interstitialId;

  /// Ad unit ID (AdMob, AppLovin) hoặc placement ID (Unity) của reward.
  final String rewardedId;

  /// Ad unit ID của banner (AdMob, AppLovin).
  final String bannerId;

  bool get isConfigured => appId.isNotEmpty && interstitialId.isNotEmpty;

  /// True khi mạng có đủ ID để tải quảng cáo reward.
  bool get rewardedConfigured => appId.isNotEmpty && rewardedId.isNotEmpty;

  /// True khi mạng có đủ ID để tải banner.
  bool get bannerConfigured => appId.isNotEmpty && bannerId.isNotEmpty;
}

/// Mọi ID quảng cáo nằm ở đây, riêng cho từng nền tảng và mạng (BR5.2,
/// NFR2.3). Đây là định danh công khai đi kèm bản phát hành, không phải khóa
/// bí mật. Bản debug dùng ID thử để không tạo lượt hiện hay bấm thật (NFR2.4).
abstract final class AdUnitIds {
  /// ID thử công khai của Google cho AdMob.
  static const AdNetworkIds _admobTestAndroid = AdNetworkIds(
    appId: 'ca-app-pub-3940256099942544~3347511713',
    interstitialId: 'ca-app-pub-3940256099942544/1033173712',
    rewardedId: 'ca-app-pub-3940256099942544/5224354917',
    bannerId: 'ca-app-pub-3940256099942544/9214589741',
  );
  static const AdNetworkIds _admobTestIos = AdNetworkIds(
    appId: 'ca-app-pub-3940256099942544~1458002511',
    interstitialId: 'ca-app-pub-3940256099942544/4411468910',
    rewardedId: 'ca-app-pub-3940256099942544/1712485313',
    bannerId: 'ca-app-pub-3940256099942544/2435281174',
  );

  // TODO(release): điền ID thật trước khi phát hành. Để trống thì mạng đó
  // không có quảng cáo ở bản phát hành; game vẫn chạy bình thường (BR2.4).
  // ID ứng dụng AdMob thật cũng phải thay trong AndroidManifest.xml và
  // Info.plist.
  static const AdNetworkIds _admobReleaseAndroid = AdNetworkIds();
  static const AdNetworkIds _admobReleaseIos = AdNetworkIds();

  // TODO(release): Unity Ads không có game ID thử công khai. Điền game ID
  // và placement ID của bạn; khi chạy bản debug, SDK Unity tự ở chế độ thử.
  static const AdNetworkIds _unityAndroid = AdNetworkIds();
  static const AdNetworkIds _unityIos = AdNetworkIds();

  // TODO(release): điền SDK key và ad unit ID của AppLovin MAX. AppLovin
  // không có ID thử công khai; bật chế độ thử trong bảng điều khiển MAX.
  static const AdNetworkIds _applovinAndroid = AdNetworkIds();
  static const AdNetworkIds _applovinIos = AdNetworkIds();

  static bool get _ios => !kIsWeb && Platform.isIOS;

  static AdNetworkIds get admob => kDebugMode
      ? (_ios ? _admobTestIos : _admobTestAndroid)
      : (_ios ? _admobReleaseIos : _admobReleaseAndroid);

  static AdNetworkIds get unity => _ios ? _unityIos : _unityAndroid;

  static AdNetworkIds get applovin => _ios ? _applovinIos : _applovinAndroid;
}
