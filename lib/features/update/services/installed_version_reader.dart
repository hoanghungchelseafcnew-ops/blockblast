import 'package:package_info_plus/package_info_plus.dart';

/// Đọc tên phiên bản đang cài (ví dụ `1.0.0`), sau interface để test không
/// cần nền tảng (NFR3.4).
abstract class InstalledVersionReader {
  const InstalledVersionReader();

  /// Tên phiên bản đang cài. Có thể ném lỗi; [AppUpdateChecker] bắt lỗi.
  Future<String> read();
}

/// Bản thật dùng `package_info_plus` (ADR-006).
class PackageInfoVersionReader extends InstalledVersionReader {
  const PackageInfoVersionReader();

  @override
  Future<String> read() async => (await PackageInfo.fromPlatform()).version;
}
