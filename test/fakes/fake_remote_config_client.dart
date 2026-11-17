import 'dart:async';

import 'package:block_blast/core/config/remote_config_client.dart';

/// Fake cấu hình được: trả JSON, ném lỗi hoặc treo (không gọi Firebase thật).
class FakeRemoteConfigClient implements RemoteConfigClient {
  FakeRemoteConfigClient({
    this.activatedValue,
    this.valueAfterFetch,
    this.fetchError,
    this.hangFetch = false,
    this.readError,
  });

  /// Giá trị đã activate từ lần trước (cached).
  String? activatedValue;

  /// Giá trị trở thành activate khi fetch thành công.
  String? valueAfterFetch;

  /// Nếu khác null, `fetchAndActivate` ném lỗi này.
  Object? fetchError;

  /// Nếu true, `fetchAndActivate` không bao giờ hoàn tất.
  bool hangFetch;

  /// Nếu khác null, `readLevelConfig` ném lỗi này.
  Object? readError;

  int configureCalls = 0;
  int fetchCalls = 0;

  @override
  Future<void> configure() async {
    configureCalls++;
  }

  @override
  Future<bool> fetchAndActivate() async {
    fetchCalls++;
    if (hangFetch) return Completer<bool>().future;
    final error = fetchError;
    if (error != null) throw error;
    if (valueAfterFetch != null) activatedValue = valueAfterFetch;
    return valueAfterFetch != null;
  }

  @override
  String? readLevelConfig() {
    final error = readError;
    if (error != null) throw error;
    return activatedValue;
  }
}
