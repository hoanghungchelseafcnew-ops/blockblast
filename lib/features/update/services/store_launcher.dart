import 'package:url_launcher/url_launcher.dart';

import '../../../core/log/gj_log.dart';
import '../logic/version_check.dart';

/// Mở trang cửa hàng, sau interface để test không cần nền tảng (NFR3.4).
abstract class StoreLauncher {
  const StoreLauncher();

  /// Mở [url] bằng ứng dụng ngoài. Trả false nếu không mở được. Không bao
  /// giờ ném lỗi.
  Future<bool> open(String url);
}

/// Bản thật dùng `url_launcher` ở chế độ mở ngoài: Google Play hoặc App
/// Store, không có thì trình duyệt hệ thống (NFR8.2).
class UrlStoreLauncher extends StoreLauncher {
  const UrlStoreLauncher();

  @override
  Future<bool> open(String url) async {
    // Kiểm tra lại ngay trước khi mở (NFR8.1).
    if (!VersionCheck.isValidStoreUrl(url)) {
      GjLog.warn('Update', 'refusing to open an invalid store link');
      return false;
    }
    try {
      final opened = await launchUrl(
        Uri.parse(url.trim()),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) GjLog.warn('Update', 'store link could not be opened');
      return opened;
    } catch (e) {
      GjLog.warn('Update', 'opening the store failed', e);
      return false;
    }
  }
}
