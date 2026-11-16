import 'package:flutter/foundation.dart';

/// Nhận một dòng log đã định dạng.
typedef GjLogSink = void Function(String line);

/// Điểm vào log duy nhất của Gemstone Journey (NFR6.10, D-O1).
///
/// Quy tắc an toàn (D-S5): không bao giờ log JSON cấu hình thô, URL đầy đủ
/// hay `err.toString()`. Với lỗi chỉ ghi `err.runtimeType`.
class GjLog {
  GjLog._();

  /// Test thay `sink` để đếm số dòng.
  static GjLogSink sink = (String line) => debugPrint(line);

  static void info(String component, String message) =>
      _write(component, 'info', message);

  static void warn(String component, String message, [Object? err]) =>
      _write(component, 'warn', message, err);

  static void error(String component, String message, [Object? err]) =>
      _write(component, 'error', message, err);

  static void _write(
    String component,
    String level,
    String message, [
    Object? err,
  ]) {
    final suffix = err == null ? '' : ': ${err.runtimeType}';
    try {
      sink('[GJ][$component][$level] $message$suffix');
    } catch (_) {
      // Log không bao giờ được làm hỏng luồng chính.
    }
  }
}
