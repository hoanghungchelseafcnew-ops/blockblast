import 'package:flutter/services.dart';

import '../../../core/audio/audio_controller.dart';

/// Âm thanh và rung khi chơi. Controller chỉ gọi interface này, nên logic ván
/// chơi test được mà không cần plugin nền tảng.
abstract class GameFeedback {
  const GameFeedback();

  void placed();
  void cleared();
  void combo();
  void gameOver();
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
}

/// Triển khai thật: `AudioController` và rung của thiết bị (giữ hành vi cũ).
class DeviceGameFeedback extends GameFeedback {
  const DeviceGameFeedback();

  @override
  void placed() {
    HapticFeedback.heavyImpact();
    AudioController.playPlace();
  }

  @override
  void cleared() => AudioController.playClear();

  @override
  void combo() => AudioController.playCombo();

  @override
  void gameOver() => AudioController.playGameOver();
}
