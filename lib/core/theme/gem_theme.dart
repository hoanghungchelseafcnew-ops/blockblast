import 'package:flutter/painting.dart';

import '../log/gj_log.dart';

/// Bảng màu của một đá quý (contract C6).
class GemPalette {
  const GemPalette({
    required this.primary,
    required this.secondary,
    required this.onPrimary,
    required this.buttonFill,
  });

  /// Màu chính: thanh tiến độ, glow, viền focus, icon gem.
  final Color primary;

  /// Màu phụ: đầu gradient nền.
  final Color secondary;

  /// Màu chữ trên nút chính.
  final Color onPrimary;

  /// Nền nút chính. Bằng [primary], riêng Amethyst đậm hơn để đạt tương phản.
  final Color buttonFill;
}

/// Nguồn màu duy nhất cho UI theo đá quý (FR12.1, C6). Khối và ô trên bảng
/// không dùng bảng này.
abstract final class GemTheme {
  /// Màu tối ở cuối gradient nền (design-system-mapping, Nền).
  static const Color backgroundEnd = Color(0xFF0F0C29);

  /// Độ đậm của màu phụ khi trộn lên [backgroundEnd] ở đầu gradient. Giữ chữ
  /// trắng trên nền đạt tương phản ≥ 4.5:1 cho cả 6 gem.
  static const double backgroundTint = 0.35;

  static const Color _dark = Color(0xFF151525);
  static const Color _white = Color(0xFFFFFFFF);

  static const Map<String, GemPalette> _palettes = <String, GemPalette>{
    'rose_quartz': GemPalette(
      primary: Color(0xFFFFB6C1),
      secondary: Color(0xFFFF69B4),
      onPrimary: _dark,
      buttonFill: Color(0xFFFFB6C1),
    ),
    'amethyst': GemPalette(
      primary: Color(0xFF9966CC),
      secondary: Color(0xFF8B008B),
      onPrimary: _white,
      buttonFill: Color(0xFF7A4FB0),
    ),
    'blue_topaz': GemPalette(
      primary: Color(0xFF4FC3F7),
      secondary: Color(0xFF0288D1),
      onPrimary: _dark,
      buttonFill: Color(0xFF4FC3F7),
    ),
    'emerald': GemPalette(
      primary: Color(0xFF50C878),
      secondary: Color(0xFF228B22),
      onPrimary: _dark,
      buttonFill: Color(0xFF50C878),
    ),
    'sapphire': GemPalette(
      primary: Color(0xFF0F52BA),
      secondary: Color(0xFF000080),
      onPrimary: _white,
      buttonFill: Color(0xFF0F52BA),
    ),
    'ruby': GemPalette(
      primary: Color(0xFFE0115F),
      secondary: Color(0xFF8B0000),
      onPrimary: _white,
      buttonFill: Color(0xFFE0115F),
    ),
  };

  /// Gem id đã biết, theo thứ tự hành trình.
  static Iterable<String> get gemIds => _palettes.keys;

  /// Bảng màu của [gemId]. Id lạ thì dùng Rose Quartz và log cảnh báo.
  static GemPalette forGem(String gemId) {
    final palette = _palettes[gemId];
    if (palette != null) return palette;
    GjLog.warn('Theme', 'unknown gem id, using rose_quartz: $gemId');
    return _palettes['rose_quartz']!;
  }

  /// Gradient nền: màu phụ trộn nhẹ lên [backgroundEnd], rồi về [backgroundEnd].
  static List<Color> backgroundGradient(GemPalette palette) {
    return <Color>[
      Color.alphaBlend(
        palette.secondary.withValues(alpha: backgroundTint),
        backgroundEnd,
      ),
      backgroundEnd,
    ];
  }
}
