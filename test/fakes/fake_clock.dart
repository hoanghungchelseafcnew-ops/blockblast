import 'package:block_blast/core/utils/clock.dart';

/// Đồng hồ giả: chỉ tiến khi test (hoặc fake) gọi [advance].
class FakeClock extends Clock {
  FakeClock([DateTime? start]) : _now = start ?? DateTime.utc(2026, 11, 17);

  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration duration) => _now = _now.add(duration);
}
