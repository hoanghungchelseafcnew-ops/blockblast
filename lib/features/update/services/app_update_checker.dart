import 'package:flutter/foundation.dart';

import '../../../core/log/gj_log.dart';
import '../../ads/models/ads_settings.dart';
import '../logic/version_check.dart';
import 'installed_version_reader.dart';

/// Quyết định có báo bản mới không và nhớ lần mở đã hiện popup
/// (u4-update-and-share, BR8.1 đến BR8.4).
///
/// Dùng cấu hình đã kích hoạt lúc khởi động, không tải thêm (NFR6.2). Không
/// bao giờ ném lỗi (NFR2.23).
class AppUpdateChecker {
  AppUpdateChecker({
    required AdsSettings settings,
    InstalledVersionReader reader = const PackageInfoVersionReader(),
    bool Function()? isIos,
  }) : _settings = settings,
       _reader = reader,
       _isIos = isIos ?? _platformIsIos;

  static const String _log = 'Update';

  final AdsSettings _settings;
  final InstalledVersionReader _reader;
  final bool Function() _isIos;

  /// Số lần mở ứng dụng lúc popup hiện gần nhất; null nếu chưa hiện.
  int? _shownAtOpen;

  static bool _platformIsIos() => defaultTargetPlatform == TargetPlatform.iOS;

  /// Đường dẫn cửa hàng nếu có bản mới, hoặc null (BR8.1 đến BR8.3).
  Future<String?> check() async {
    final ios = _isIos();
    final url = VersionCheck.storeUrlFor(_settings, ios: ios);
    if (url == null) {
      GjLog.info(_log, 'no valid store link, skipping update check');
      return null;
    }
    final configured = VersionCheck.configuredVersionFor(_settings, ios: ios);
    if (VersionCheck.parseVersion(configured) == null) {
      GjLog.info(_log, 'no valid configured version, skipping update check');
      return null;
    }
    String installed;
    try {
      installed = await _reader.read();
    } catch (e) {
      GjLog.warn(_log, 'reading the installed version failed', e);
      return null;
    }
    if (!VersionCheck.isNewer(installed: installed, configured: configured)) {
      return null;
    }
    GjLog.info(_log, 'update available');
    return url;
  }

  /// True nếu popup chưa hiện ở lần mở [appOpen] (BR8.4). Với quảng cáo
  /// không chạy, [appOpen] luôn là 0: popup hiện tối đa một lần mỗi lần
  /// khởi động.
  bool canShowFor(int appOpen) {
    final shownAt = _shownAtOpen;
    return shownAt == null || appOpen > shownAt;
  }

  /// Ghi là popup đã hiện ở lần mở [appOpen].
  void markShown(int appOpen) => _shownAtOpen = appOpen;
}
