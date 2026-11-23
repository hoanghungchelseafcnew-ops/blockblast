import '../models/block_model.dart';

/// Tỉ lệ chọn khối cho một cặp (level, độ đầy bảng).
class TrayRates {
  const TrayRates({
    required this.smallRate,
    required this.mediumRate,
    required this.largeRate,
    required this.rescueRate,
  });

  final double smallRate;
  final double mediumRate;
  final double largeRate;
  final double rescueRate;
}

/// Mức bảo đảm giải được mà một khay đạt.
enum SolvabilityTier {
  /// Mọi thứ tự đặt 3 khối đều có cách đặt hết.
  strict,

  /// Tồn tại ít nhất một thứ tự đặt hết 3 khối.
  relaxed,

  /// Khay ba khối 1x1.
  fallback,
}

/// Kết quả chuẩn bị khay. Khay đã trả về là bất biến (BR1.1).
class TrayResult {
  TrayResult.ready(List<BlockModel> blocks, SolvabilityTier this.tier)
    : tray = List<BlockModel>.unmodifiable(blocks),
      gameOver = false;

  TrayResult.gameOver()
    : tray = const <BlockModel>[],
      tier = null,
      gameOver = true;

  /// Khay 3 khối; rỗng khi [gameOver].
  final List<BlockModel> tray;

  /// Mức bảo đảm; null khi [gameOver].
  final SolvabilityTier? tier;

  /// Không còn khay nào đặt hết được (BR1.4).
  final bool gameOver;
}
