import 'dart:math';

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

/// Triển khai thật: [AudioController] và rung của thiết bị.
class DeviceGameFeedback extends GameFeedback {
  DeviceGameFeedback(this.audio, {Random? random})
    : _random = random ?? Random();

  final AudioController audio;
  final Random _random;

  static const List<Sfx> _placeSounds = [Sfx.place, Sfx.place2, Sfx.place3];

  @override
  void placed() {
    HapticFeedback.lightImpact();
    audio.play(_placeSounds[_random.nextInt(_placeSounds.length)]);
  }

  @override
  void cleared() => audio.play(Sfx.clear);

  /// 1 dòng: chuông đơn; 2 dòng: ba nốt; từ 3 dòng: bốn nốt kèm lấp lánh.
  @override
  void clearedLines(int lines) {
    audio.play(
      lines >= 3
          ? Sfx.clear3
          : lines == 2
          ? Sfx.clear2
          : Sfx.clear,
    );
  }

  @override
  void combo() => audio.play(Sfx.combo);

  /// Combo càng cao, âm càng cao và đầy: bậc 2, bậc 3, từ bậc 4.
  @override
  void comboStreak(int streak) {
    audio.play(
      streak >= 4
          ? Sfx.combo3
          : streak == 3
          ? Sfx.combo2
          : Sfx.combo,
    );
  }

  @override
  void bombExploded() {
    HapticFeedback.heavyImpact();
    audio.play(Sfx.bomb);
  }

  @override
  void gameOver() => audio.play(Sfx.gameOver);

  @override
  void victory() => audio.play(Sfx.victory);

  @override
  void unlock() => audio.play(Sfx.unlock);

  @override
  void stopSfx() => audio.stopSfx();
}
