import '../../../core/config/remote_config_client.dart';
import '../../../core/log/gj_log.dart';
import '../models/ads_settings.dart';

/// Tên các tham số trên Remote Config (contract-summary.md, hợp đồng 1).
abstract final class AdsConfigKeys {
  static const String bannerStartVisit = 'banner_start_visit';
  static const String rewardEnabled = 'reward_enabled';
  static const String interstitialEveryNStarts = 'interstitial_every_n_starts';
  static const String adsPriority = 'ads_priority';
  static const String androidVersion = 'android_version';
  static const String androidUrl = 'android_url';
  static const String iosVersion = 'ios_version';
  static const String iosUrl = 'ios_url';
}

/// Đọc [AdsSettings] từ Remote Config đã activate (BR1.1 đến BR1.3,
/// BR2.2, BR2.3). Không bao giờ ném lỗi: mọi lỗi đều trả về mặc định.
abstract final class AdsConfig {
  static const String _log = 'AdsConfig';

  static AdsSettings read(RemoteConfigClient? client) {
    if (client == null) return AdsSettings.defaults;
    try {
      return AdsSettings(
        bannerStartVisit: _positiveInt(
          client,
          AdsConfigKeys.bannerStartVisit,
          AdsSettings.defaultBannerStartVisit,
        ),
        rewardEnabled: _bool(
          client,
          AdsConfigKeys.rewardEnabled,
          AdsSettings.defaultRewardEnabled,
        ),
        interstitialEveryNStarts: _positiveInt(
          client,
          AdsConfigKeys.interstitialEveryNStarts,
          AdsSettings.defaultInterstitialEveryNStarts,
        ),
        adsPriority: parsePriority(
          client.readString(AdsConfigKeys.adsPriority),
        ),
        androidVersion: _text(client, AdsConfigKeys.androidVersion),
        androidUrl: _text(client, AdsConfigKeys.androidUrl),
        iosVersion: _text(client, AdsConfigKeys.iosVersion),
        iosUrl: _text(client, AdsConfigKeys.iosUrl),
      );
    } catch (e) {
      GjLog.warn(_log, 'reading ad settings failed, using defaults', e);
      return AdsSettings.defaults;
    }
  }

  /// Chuẩn hóa `ads_priority`: rỗng hoặc thiếu thì mặc định (BR2.2), tên lạ
  /// bị bỏ (BR2.3), tên trùng chỉ giữ lần đầu. Nếu không còn tên nào hợp lệ
  /// thì cũng dùng mặc định.
  static List<AdNetwork> parsePriority(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return AdsSettings.defaultAdsPriority;
    }
    final result = <AdNetwork>[];
    var unknown = 0;
    for (final part in raw.split(',')) {
      if (part.trim().isEmpty) continue;
      final network = AdNetwork.fromKey(part);
      if (network == null) {
        unknown++;
        continue;
      }
      if (!result.contains(network)) result.add(network);
    }
    if (unknown > 0) {
      // Không ghi giá trị thô (quy tắc an toàn của GjLog).
      GjLog.warn(
        _log,
        'ads_priority: $unknown unknown network name(s) ignored',
      );
    }
    if (result.isEmpty) {
      GjLog.warn(_log, 'ads_priority has no known network, using default');
      return AdsSettings.defaultAdsPriority;
    }
    return List<AdNetwork>.unmodifiable(result);
  }

  static int _positiveInt(RemoteConfigClient client, String key, int fallback) {
    final text = client.readString(key);
    if (text == null) return fallback;
    final value = client.readInt(key);
    if (value == null || value < 1) {
      GjLog.warn(_log, '$key is not a positive integer, using default');
      return fallback;
    }
    return value;
  }

  static bool _bool(RemoteConfigClient client, String key, bool fallback) {
    final text = client.readString(key);
    if (text == null) return fallback;
    final value = client.readBool(key);
    if (value == null) {
      GjLog.warn(_log, '$key is not true or false, using default');
      return fallback;
    }
    return value;
  }

  static String _text(RemoteConfigClient client, String key) =>
      client.readString(key)?.trim() ?? '';
}
