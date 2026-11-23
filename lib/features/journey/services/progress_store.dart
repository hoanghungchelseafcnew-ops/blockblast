import 'package:shared_preferences/shared_preferences.dart';

/// Lớp bọc thay thế được quanh SharedPreferences, để test giả lập ghi lỗi
/// (ADR-009). Chỉ `ProgressRepository` dùng lớp này.
abstract class ProgressStore {
  /// Mở kho lưu trữ. Có thể throw; repository thử lại một lần.
  Future<void> init();

  /// Giá trị thô của [key] (đồng bộ sau [init]), hoặc null nếu chưa có.
  Object? read(String key);

  Future<void> writeString(String key, String value);

  Future<void> writeBool(String key, bool value);

  Future<void> writeInt(String key, int value);

  /// Xóa [key]. Không lỗi nếu key chưa có.
  Future<void> remove(String key);
}

/// Triển khai thật bằng SharedPreferences.
class SharedPreferencesProgressStore implements ProgressStore {
  SharedPreferences? _prefs;

  SharedPreferences get _ready {
    final prefs = _prefs;
    if (prefs == null) throw StateError('ProgressStore not initialised');
    return prefs;
  }

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Object? read(String key) => _ready.get(key);

  @override
  Future<void> writeString(String key, String value) async =>
      _check(await _ready.setString(key, value), 'setString');

  @override
  Future<void> writeBool(String key, bool value) async =>
      _check(await _ready.setBool(key, value), 'setBool');

  @override
  Future<void> writeInt(String key, int value) async =>
      _check(await _ready.setInt(key, value), 'setInt');

  @override
  Future<void> remove(String key) async =>
      _check(await _ready.remove(key), 'remove');

  /// SharedPreferences báo lỗi ghi bằng `false`; đổi thành exception để
  /// repository đánh dấu dirty và thử lại (BR3.3).
  static void _check(bool ok, String operation) {
    if (!ok) throw StateError('$operation returned false');
  }
}
