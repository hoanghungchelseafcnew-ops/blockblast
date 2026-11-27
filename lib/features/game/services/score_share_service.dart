import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/log/gj_log.dart';
import '../../update/logic/version_check.dart';

/// Chia sẻ ảnh chụp màn hình kèm điểm. Abstract để widget test không cần
/// plugin nền tảng.
abstract class ScoreShareService {
  const ScoreShareService();

  /// Tên game dùng trong văn bản chia sẻ (FR2.4).
  static const String gameName = 'Block Jewel';

  /// Văn bản chia sẻ ở Game Over (BR1.6).
  static String scoreShareText(int score) => 'I scored $score in $gameName!';

  /// Văn bản chia sẻ ở Victory (BR1.3).
  static String victoryShareText(String levelName, int score) =>
      'I cleared $levelName with $score points in $gameName!';

  /// Nối [storeUrl] vào cuối [text] ở một dòng riêng khi đường dẫn hợp lệ;
  /// ngược lại giữ nguyên [text] (u4-update-and-share, BR9.1, BR8.3).
  static String withStoreLink(String text, String? storeUrl) {
    final url = storeUrl?.trim();
    if (url == null || !VersionCheck.isValidStoreUrl(url)) return text;
    return '$text\n$url';
  }

  /// Chia sẻ ảnh màn Game Over.
  Future<void> shareScore({
    required ScreenshotController screenshot,
    required int score,
  });

  /// Chia sẻ ảnh toàn màn hình khi vượt level (FR3.2).
  Future<void> shareVictory({
    required ScreenshotController screenshot,
    required String levelName,
    required int score,
  });
}

/// Triển khai thật bằng `screenshot`, `path_provider` và `share_plus`.
///
/// Ảnh chỉ ghi vào thư mục tạm và chỉ gửi khi người chơi bấm SHARE (NFR6).
/// Lỗi chụp, ghi file hay mở khung chia sẻ chỉ được ghi log (BR1.4).
class PlatformScoreShareService extends ScoreShareService {
  const PlatformScoreShareService({this.storeUrl});

  /// Đường dẫn cửa hàng của nền tảng đang chạy, nối vào cuối nội dung
  /// (FR7). Null hoặc sai dạng thì nội dung giữ nguyên.
  final String? storeUrl;

  @override
  Future<void> shareScore({
    required ScreenshotController screenshot,
    required int score,
  }) => _captureAndShare(
    screenshot: screenshot,
    fileName: 'score.png',
    text: ScoreShareService.withStoreLink(
      ScoreShareService.scoreShareText(score),
      storeUrl,
    ),
    what: 'the score',
  );

  @override
  Future<void> shareVictory({
    required ScreenshotController screenshot,
    required String levelName,
    required int score,
  }) => _captureAndShare(
    screenshot: screenshot,
    fileName: 'victory.png',
    text: ScoreShareService.withStoreLink(
      ScoreShareService.victoryShareText(levelName, score),
      storeUrl,
    ),
    what: 'the victory',
  );

  Future<void> _captureAndShare({
    required ScreenshotController screenshot,
    required String fileName,
    required String text,
    required String what,
  }) async {
    try {
      final Uint8List? image = await screenshot.capture();
      if (image == null) {
        GjLog.error('Game', 'sharing $what failed: no screenshot');
        return;
      }
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/$fileName';
      await File(path).writeAsBytes(image);
      await Share.shareXFiles([XFile(path)], text: text);
    } catch (e) {
      GjLog.error('Game', 'sharing $what failed', e);
    }
  }
}
