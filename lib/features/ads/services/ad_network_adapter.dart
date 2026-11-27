import 'package:flutter/widgets.dart';

import '../models/ads_settings.dart';

/// Kết quả tải quảng cáo của một mạng (contract-summary.md, hợp đồng 4).
enum AdLoadResult { ready, noFill, error }

/// Kết quả hiện một quảng cáo reward của một mạng (u2-reward-ads, BR6.3,
/// BR6.4).
enum RewardShowResult {
  /// Người chơi xem đủ và được thưởng.
  earned,

  /// Quảng cáo đã hiện nhưng người chơi đóng trước khi được thưởng.
  closedEarly,

  /// Không hiện được.
  failed,
}

/// Một banner đã tải xong của một mạng (u3-banner, NFR3.3).
///
/// Người giữ banner phải gọi [dispose] đúng một lần khi không dùng nữa.
abstract class LoadedBanner {
  /// Chiều cao logic của banner, tính trước khi tải (NFR2.18).
  double get height;

  /// Phần tử giao diện hiện banner.
  Widget build();

  /// Giải phóng tài nguyên SDK (NFR2.21).
  void dispose();
}

/// Interface chung cho mỗi mạng quảng cáo (ADR-001). Mỗi cài đặt bọc một SDK
/// và không bao giờ để lỗi SDK thoát ra ngoài (NFR2.1): lỗi trở thành
/// [AdLoadResult.error] hoặc `false`.
abstract class AdNetworkAdapter {
  AdNetwork get network;

  /// Khởi tạo SDK. Gọi một lần sau khi đồng ý đã được xử lý.
  Future<void> initialize({required bool personalized});

  /// Tải trước một interstitial.
  Future<AdLoadResult> loadInterstitial({required bool personalized});

  /// Hiện interstitial đã tải và chờ đến khi nó đóng. Trả `true` nếu quảng
  /// cáo đã hiện, `false` nếu không hiện được.
  Future<bool> showInterstitial();

  /// Tải trước một quảng cáo reward.
  Future<AdLoadResult> loadRewarded({required bool personalized});

  /// Hiện quảng cáo reward đã tải và chờ đến khi nó đóng.
  Future<RewardShowResult> showRewarded();

  /// Tải một banner thích ứng rộng [width]. Trả null nếu mạng không có
  /// banner hoặc không hỗ trợ banner (u3-banner).
  Future<LoadedBanner?> loadBanner({
    required double width,
    required bool personalized,
  });
}
