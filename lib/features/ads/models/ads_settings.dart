/// Các mạng quảng cáo mà ứng dụng tự điều phối (FR5, ADR-001).
enum AdNetwork {
  admob('admob'),
  unity('unity'),
  applovin('applovin');

  const AdNetwork(this.key);

  /// Tên dùng trong tham số `ads_priority` trên Remote Config.
  final String key;

  /// Mạng có tên [key], hoặc null nếu tên không nhận ra (BR2.3).
  static AdNetwork? fromKey(String key) {
    final normalized = key.trim().toLowerCase();
    for (final network in values) {
      if (network.key == normalized) return network;
    }
    return null;
  }
}

/// Cấu hình quảng cáo và phiên bản đã được kiểm tra, chỉ đọc (entities.md).
///
/// Mọi trường luôn có giá trị hợp lệ: giá trị thiếu hay sai đã được thay bằng
/// mặc định ở `AdsConfig` (BR1.2, BR1.3).
class AdsSettings {
  const AdsSettings({
    this.bannerStartVisit = defaultBannerStartVisit,
    this.rewardEnabled = defaultRewardEnabled,
    this.interstitialEveryNStarts = defaultInterstitialEveryNStarts,
    this.adsPriority = defaultAdsPriority,
    this.androidVersion = '',
    this.androidUrl = '',
    this.iosVersion = '',
    this.iosUrl = '',
  });

  static const int defaultBannerStartVisit = 3;
  static const bool defaultRewardEnabled = true;
  static const int defaultInterstitialEveryNStarts = 3;
  static const List<AdNetwork> defaultAdsPriority = <AdNetwork>[
    AdNetwork.admob,
    AdNetwork.unity,
    AdNetwork.applovin,
  ];

  /// Toàn bộ giá trị mặc định, dùng khi không tải được cấu hình (BR1.2).
  static const AdsSettings defaults = AdsSettings();

  /// Banner chỉ hiện từ lần mở ứng dụng thứ N (FR2.2).
  final int bannerStartVisit;

  /// Bật hoặc tắt nút reward ads (FR3.1).
  final bool rewardEnabled;

  /// Interstitial sau mỗi N lần bấm Start (FR4.2).
  final int interstitialEveryNStarts;

  /// Thứ tự thử các mạng, đã bỏ tên lạ và không trùng (FR5).
  final List<AdNetwork> adsPriority;

  final String androidVersion;
  final String androidUrl;
  final String iosVersion;
  final String iosUrl;
}
