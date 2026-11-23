import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

import '../../../core/log/gj_log.dart';
import '../models/level.dart';

/// Tạo provider cho một URL ảnh. Mặc định là [CachedNetworkImageProvider], lưu
/// cache trên đĩa (FR5.4, AC7.2.1). Test thay bằng bản giả.
typedef NetworkImageFactory = ImageProvider<Object> Function(String url);

ImageProvider<Object> _cachedNetwork(String url) =>
    CachedNetworkImageProvider(url);

/// Nạp ảnh nền của level: asset trước, ảnh mạng từ Remote Config nếu có
/// (FR5.1, FR5.2). Không dùng `firebase_storage` (AC7.2.1).
class BackgroundImageService {
  BackgroundImageService({NetworkImageFactory? networkFactory})
    : _networkFactory = networkFactory ?? _cachedNetwork;

  /// Bản dùng chung của app, để provider mạng được dùng lại giữa các màn.
  static final BackgroundImageService instance = BackgroundImageService();

  final NetworkImageFactory _networkFactory;

  /// Provider mạng theo URL. Dùng lại cho cùng URL trong phiên để ảnh đã tải
  /// lấy từ cache, không tải lại (AC7.2.3).
  final Map<String, ImageProvider<Object>> _network =
      <String, ImageProvider<Object>>{};

  /// Ảnh asset của [level], luôn có (offline, AC7.4.1).
  ImageProvider<Object> assetFor(Level level) => AssetImage(level.assetPath);

  /// Ảnh mạng của [level], hoặc null khi Remote Config không có URL hợp lệ.
  /// URL đã được `ImageUrlPolicy` kiểm ở U1.
  ImageProvider<Object>? networkFor(Level level) {
    final url = level.backgroundUrl;
    if (url == null || url.isEmpty) return null;
    return _network.putIfAbsent(url, () => _networkFactory(url));
  }

  /// Nạp sẵn ảnh của [level] (FR5.4, AC7.3.1). Không bao giờ ném lỗi: lỗi chỉ
  /// được log với `levelId`, không log URL.
  Future<void> precache(BuildContext context, Level level) async {
    final network = networkFor(level);
    await Future.wait<void>([
      _precacheOne(context, assetFor(level), level, 'asset'),
      if (network != null) _precacheOne(context, network, level, 'network'),
    ]);
  }

  Future<void> _precacheOne(
    BuildContext context,
    ImageProvider<Object> provider,
    Level level,
    String kind,
  ) async {
    try {
      await precacheImage(
        provider,
        context,
        onError: (Object e, StackTrace? _) {
          GjLog.warn(
            'Background',
            'precache $kind failed: levelId=${level.levelIndex}',
            e,
          );
        },
      );
    } catch (e) {
      GjLog.warn(
        'Background',
        'precache $kind failed: levelId=${level.levelIndex}',
        e,
      );
    }
  }
}
