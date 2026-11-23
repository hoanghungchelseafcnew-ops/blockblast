import 'package:flutter/painting.dart';

/// Token chữ dùng font đóng gói trong `assets/fonts/` để chạy offline
/// (design-system-mapping, Typography).
///
/// Montserrat là variable font, nên mỗi style đặt cả `fontWeight` lẫn trục
/// `wght` để weight hiển thị đúng trên mọi nền tảng.
abstract final class AppTypography {
  static const String displayFamily = 'Righteous';
  static const String bodyFamily = 'Montserrat';

  static TextStyle _righteous(double size, {double letterSpacing = 0}) {
    return TextStyle(
      fontFamily: displayFamily,
      fontSize: size,
      letterSpacing: letterSpacing,
      color: const Color(0xFFFFFFFF),
    );
  }

  static TextStyle _montserrat(double size, FontWeight weight, Color color) {
    return TextStyle(
      fontFamily: bodyFamily,
      fontSize: size,
      fontWeight: weight,
      fontVariations: <FontVariation>[
        FontVariation('wght', weight.value.toDouble()),
      ],
      color: color,
    );
  }

  /// Tiêu đề lớn: Home, "JOURNEY COMPLETE!".
  static TextStyle display({double size = 36}) =>
      _righteous(size, letterSpacing: 2);

  /// "Level Complete!", "GAME OVER", "Quit this level?".
  static TextStyle headline({double size = 28}) => _righteous(size);

  /// Nhãn nút, tên level.
  static TextStyle title({Color color = const Color(0xFFFFFFFF)}) =>
      _montserrat(20, FontWeight.w700, color);

  /// Nội dung, điểm.
  static TextStyle body({
    double size = 16,
    Color color = const Color(0xFFFFFFFF),
  }) => _montserrat(size, FontWeight.w600, color);

  /// BEST, % tiến độ.
  static TextStyle caption({Color color = const Color(0xB3FFFFFF)}) =>
      _montserrat(14, FontWeight.w500, color);
}
