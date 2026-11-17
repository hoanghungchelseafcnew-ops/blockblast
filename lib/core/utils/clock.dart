/// Đồng hồ tiêm được để test hạn chót khởi động mà không chờ thật.
abstract class Clock {
  const Clock();

  DateTime now();
}

class SystemClock extends Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
