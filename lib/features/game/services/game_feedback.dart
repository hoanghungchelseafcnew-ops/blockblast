import '../../../core/audio/audio_controller.dart';
import '../../../core/audio/sfx.dart';

/// Âm thanh và rung khi chơi. Controller chỉ gọi interface này, nên logic ván
/// chơi test được mà không cần plugin nền tảng.
abstract class GameFeedback {
  const GameFeedback();

  void placed();
  void cleared();
  void combo();
  void gameOver();

  /// Ăn [lines] dòng một lượt. Mặc định phát âm ăn dòng thường.
  void clearedLines(int lines) => cleared();

  /// Combo bậc [streak] (từ 2). Mặc định phát âm combo thường.
  void comboStreak(int streak) => combo();

  /// Một khối bom nổ khi ăn dòng.
  void bombExploded() {}

  /// Mở màn Victory (FR6.1).
  void victory();

  /// Mở khóa đá quý, phát sau [victory] (FR6.2).
  void unlock();

  /// Dừng âm thanh đang phát khi rời màn Victory (interaction-spec).
  void stopSfx();
}

/// Không làm gì. Mặc định của controller và của test.
class NoopGameFeedback extends GameFeedback {
  const NoopGameFeedback();

  @override
  void placed() {}

  @override
  void cleared() {}

  @override
  void combo() {}

  @override
  void gameOver() {}

  @override
  void victory() {}

  @override
  void unlock() {}

  @override
  void stopSfx() {}
}

/// Triển khai thật bằng [AudioController].
///
/// Theo yêu cầu thay đổi CR-2 (2026-11-27): khi chơi không có âm thanh và
/// không rung. Chỉ phát âm qua màn ([victory]) và mở khóa viên đá
/// ([unlock]). Endless không có qua màn nên im lặng hoàn toàn.
class DeviceGameFeedback extends GameFeedback {
  DeviceGameFeedback(this.audio);

  final AudioController audio;

  @override
  void placed() {}

  @override
  void cleared() {}

  @override
  void clearedLines(int lines) {}

  @override
  void combo() {}

  @override
  void comboStreak(int streak) {}

  @override
  void bombExploded() {}

  @override
  void gameOver() {}

  @override
  void victory() => audio.play(Sfx.victory);

  @override
  void unlock() => audio.play(Sfx.unlock);

  @override
  void stopSfx() => audio.stopSfx();
}
