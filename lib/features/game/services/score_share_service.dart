import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/log/gj_log.dart';

/// Chia sẻ ảnh chụp màn hình kèm điểm. Abstract để widget test không cần
/// plugin nền tảng.
abstract class ScoreShareService {
  const ScoreShareService();

  Future<void> shareScore({
    required ScreenshotController screenshot,
    required int score,
  });
}

/// Triển khai thật bằng `screenshot`, `path_provider` và `share_plus`.
class PlatformScoreShareService extends ScoreShareService {
  const PlatformScoreShareService();

  @override
  Future<void> shareScore({
    required ScreenshotController screenshot,
    required int score,
  }) async {
    try {
      final Uint8List? image = await screenshot.capture();
      if (image == null) return;
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/score.png';
      await File(path).writeAsBytes(image);
      await Share.shareXFiles(
        [XFile(path)],
        text: 'I scored $score in Block Crush! 🎮✨',
      );
    } catch (e) {
      GjLog.error('Game', 'sharing the score failed', e);
    }
  }
}
