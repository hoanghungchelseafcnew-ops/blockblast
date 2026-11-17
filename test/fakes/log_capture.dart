import 'package:block_blast/core/log/gj_log.dart';
import 'package:flutter_test/flutter_test.dart';

/// Thu các dòng GjLog trong một test và khôi phục sink khi xong.
class LogCapture {
  final List<String> lines = [];

  /// Gọi trong `setUp`. Tự khôi phục sink bằng `addTearDown`.
  void start() {
    final previous = GjLog.sink;
    GjLog.sink = lines.add;
    addTearDown(() => GjLog.sink = previous);
  }

  Iterable<String> where(String needle) => lines.where((l) => l.contains(needle));

  bool get leaksUrlOrRawJson =>
      lines.any((l) => l.contains('https://') || l.contains('{"'));
}
