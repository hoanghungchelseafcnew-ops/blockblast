import 'package:flutter/services.dart';

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

/// Triển khai thật: [AudioController] và rung của thiết bị.
class DeviceGameFeedback extends GameFeedback {
  const DeviceGameFeedback(this.audio);

  final AudioController audio;

  @override
  void placed() {
    HapticFeedback.heavyImpact();
    audio.play(Sfx.place);
  }

  @override
  void cleared() => audio.play(Sfx.clear);

  @override
  void combo() => audio.play(Sfx.combo);

  @override
  void gameOver() => audio.play(Sfx.gameOver);

  @override
  void victory() => audio.play(Sfx.victory);

  @override
  void unlock() => audio.play(Sfx.unlock);

  @override
  void stopSfx() => audio.stopSfx();
}
