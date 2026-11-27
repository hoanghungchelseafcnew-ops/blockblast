/// Tên parameter Remote Config chứa JSON cấu hình level (contract E1).
const String levelConfigKey = 'level_config';

/// Cổng tới Remote Config. Abstract để test dùng fake, không gọi Firebase thật.
abstract class RemoteConfigClient {
  /// Đặt `minimumFetchInterval` 12 giờ và `fetchTimeout` 2 giây (D-R2).
  Future<void> configure();

  /// Fetch rồi activate. Có thể throw hoặc treo: caller áp timeout.
  Future<bool> fetchAndActivate();

  /// JSON `level_config` đang activate từ nguồn remote, hoặc null nếu chưa có.
  /// Không bao giờ trả giá trị mặc định của SDK.
  String? readLevelConfig();

  /// Giá trị chuỗi của [key] từ nguồn remote, hoặc null nếu chưa có hay rỗng
  /// (u1-ads-core, ADR-004). Không bao giờ trả giá trị mặc định của SDK.
  String? readString(String key);

  /// Giá trị số nguyên của [key] từ nguồn remote, hoặc null nếu chưa có hay
  /// không phải số nguyên. Kiểm tra miền giá trị là việc của caller.
  int? readInt(String key);

  /// Giá trị bật/tắt của [key] từ nguồn remote, hoặc null nếu chưa có hay
  /// không phải `true`/`false`.
  bool? readBool(String key);
}
