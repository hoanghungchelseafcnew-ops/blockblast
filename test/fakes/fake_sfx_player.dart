import 'package:block_blast/core/audio/audio_controller.dart';

/// Player âm thanh giả: không phát gì, ghi lại các lần gọi.
class FakeSfxPlayer implements SfxPlayer {
  final List<String> played = <String>[];
  int stops = 0;

  /// Nếu true, `play` ném lỗi (giả lập thiếu file hoặc plugin hỏng).
  bool failPlay = false;

  /// Nếu true, `stop` ném lỗi.
  bool failStop = false;

  @override
  Future<void> play(String asset) async {
    if (failPlay) throw StateError('play failed');
    played.add(asset);
  }

  @override
  Future<void> stop() async {
    if (failStop) throw StateError('stop failed');
    stops++;
  }
}
