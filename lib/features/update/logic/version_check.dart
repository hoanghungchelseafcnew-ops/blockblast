import '../../ads/models/ads_settings.dart';

/// Logic thuần cho kiểm tra phiên bản và đường dẫn cửa hàng
/// (u4-update-and-share, rules.md). Không phụ thuộc nền tảng.
abstract final class VersionCheck {
  static final RegExp _numeric = RegExp(r'^\d+(\.\d+)*$');

  /// Các phần số của [raw], bỏ phần số build sau `+` (BR8.1). Trả null nếu
  /// không phải các số nguyên không âm cách nhau bằng dấu chấm.
  static List<int>? parseVersion(String raw) {
    final name = raw.trim().split('+').first;
    if (name.isEmpty || name.length > 32 || !_numeric.hasMatch(name)) {
      return null;
    }
    return name.split('.').map(int.parse).toList();
  }

  /// So [a] với [b] từng phần từ trái sang phải, phần thiếu là 0 (BR8.2).
  /// Trả số âm nếu [a] nhỏ hơn, 0 nếu bằng, số dương nếu lớn hơn.
  static int compareVersions(List<int> a, List<int> b) {
    final length = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < length; i++) {
      final x = i < a.length ? a[i] : 0;
      final y = i < b.length ? b[i] : 0;
      if (x != y) return x < y ? -1 : 1;
    }
    return 0;
  }

  /// True khi [installed] thấp hơn [configured]. Một trong hai sai dạng thì
  /// không có bản mới (BR8.1).
  static bool isNewer({required String installed, required String configured}) {
    final current = parseVersion(installed);
    final latest = parseVersion(configured);
    if (current == null || latest == null) return false;
    return compareVersions(current, latest) < 0;
  }

  /// Đường dẫn hợp lệ: URL tuyệt đối, scheme `https`, có tên máy chủ, không
  /// có khoảng trắng hay ký tự điều khiển (BR8.3, NFR8.1).
  static bool isValidStoreUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty || value.length > 2048) return false;
    if (value.codeUnits.any((c) => c <= 0x20 || c == 0x7f)) return false;
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return uri.isAbsolute && uri.scheme == 'https' && uri.host.isNotEmpty;
  }

  /// Đường dẫn cửa hàng hợp lệ của nền tảng đang chạy, hoặc null.
  static String? storeUrlFor(AdsSettings settings, {required bool ios}) {
    final url = (ios ? settings.iosUrl : settings.androidUrl).trim();
    return isValidStoreUrl(url) ? url : null;
  }

  /// Phiên bản trên cấu hình của nền tảng đang chạy.
  static String configuredVersionFor(
    AdsSettings settings, {
    required bool ios,
  }) => ios ? settings.iosVersion : settings.androidVersion;
}
