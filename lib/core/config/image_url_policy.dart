import '../log/gj_log.dart';

/// Chính sách URL ảnh nền (BR1.3, ADR-006, D-S2).
///
/// Không bao giờ throw và không bao giờ log URL: chỉ ghi lý do.
class ImageUrlPolicy {
  const ImageUrlPolicy._();

  static const String storageApiHost = 'firebasestorage.googleapis.com';
  static const String storageAppSuffix = '.firebasestorage.app';

  /// True khi [url] được phép dùng làm ảnh nền.
  static bool isAllowed(String? url) => rejectionReason(url) == null;

  /// Lý do [url] bị loại, hoặc null nếu hợp lệ. Chuỗi rỗng hoặc chỉ khoảng
  /// trắng nghĩa là "không có URL" và trả `empty`.
  static String? rejectionReason(String? url) {
    if (url == null || url.trim().isEmpty) return 'empty';
    try {
      final uri = Uri.tryParse(url.trim());
      if (uri == null) return 'unparseable';
      if (uri.scheme != 'https') return 'scheme';
      if (uri.userInfo.isNotEmpty) return 'userinfo';
      if (uri.hasPort && uri.port != 443) return 'port';
      if (uri.fragment.isNotEmpty) return 'fragment';
      if (!_isAllowedHost(uri.host.toLowerCase())) return 'host';
      // Giải mã phần trăm trước khi tìm `..` nên `%2e%2e` cũng bị loại.
      // `Uri.decodeFull` ném lỗi với chuỗi như `%zz`.
      final decoded = Uri.decodeFull(uri.path);
      if (decoded.split('/').contains('..')) return 'path_traversal';
      return null;
    } catch (e) {
      GjLog.warn('LevelConfig', 'image url check failed', e);
      return 'invalid_encoding';
    }
  }

  static bool _isAllowedHost(String host) {
    if (host == storageApiHost) return true;
    if (!host.endsWith(storageAppSuffix)) return false;
    final prefix = host.substring(0, host.length - storageAppSuffix.length);
    if (prefix.isEmpty) return false;
    return prefix.split('.').every((label) => label.isNotEmpty);
  }
}
