import 'package:flutter/material.dart';

/// Danh mục hình khối và bảng màu (chuyển từ `BlockGenerator`, giữ nguyên giá
/// trị: BR5.3). Không còn tự sinh khay; việc đó thuộc `TrayGenerator`.
class BlockCatalog {
  const BlockCatalog._();

  /// Bảng màu khối.
  static const List<Color> colors = [
    Color(0xFFFF3366), // Pink/Red
    Color(0xFF33CCFF), // Light Blue
    Color(0xFFFFCC00), // Yellow
    Color(0xFF9933FF), // Purple
    Color(0xFF33FF99), // Green
    Color(0xFFFF9933), // Orange
    Color(0xFF0066FF), // Dark Blue
  ];

  /// Hình nhỏ: 1x1, 1x2, 2x1, 2x2 và bốn chữ L nhỏ.
  static const List<List<List<int>>> small = [
    [
      [1],
    ],
    [
      [1, 1],
    ],
    [
      [1],
      [1],
    ],
    [
      [1, 1],
      [1, 1],
    ],
    [
      [1, 1],
      [1, 0],
    ],
    [
      [1, 1],
      [0, 1],
    ],
    [
      [1, 0],
      [1, 1],
    ],
    [
      [0, 1],
      [1, 1],
    ],
  ];

  /// Hình vừa: 1x3, 3x1, 1x4, 4x1, chữ T và chữ Z.
  static const List<List<List<int>>> medium = [
    [
      [1, 1, 1],
    ],
    [
      [1],
      [1],
      [1],
    ],
    [
      [1, 1, 1, 1],
    ],
    [
      [1],
      [1],
      [1],
      [1],
    ],
    [
      [1, 1, 1],
      [0, 1, 0],
    ],
    [
      [0, 1, 0],
      [1, 1, 1],
    ],
    [
      [1, 0],
      [1, 1],
      [1, 0],
    ],
    [
      [0, 1],
      [1, 1],
      [0, 1],
    ],
    [
      [1, 1, 0],
      [0, 1, 1],
    ],
    [
      [0, 1, 1],
      [1, 1, 0],
    ],
  ];

  /// Hình lớn: 3x3, 1x5, 5x1 và bốn chữ L lớn.
  static const List<List<List<int>>> large = [
    [
      [1, 1, 1],
      [1, 1, 1],
      [1, 1, 1],
    ],
    [
      [1, 1, 1, 1, 1],
    ],
    [
      [1],
      [1],
      [1],
      [1],
      [1],
    ],
    [
      [1, 0, 0],
      [1, 0, 0],
      [1, 1, 1],
    ],
    [
      [0, 0, 1],
      [0, 0, 1],
      [1, 1, 1],
    ],
    [
      [1, 1, 1],
      [1, 0, 0],
      [1, 0, 0],
    ],
    [
      [1, 1, 1],
      [0, 0, 1],
      [0, 0, 1],
    ],
  ];

  /// Mọi hình, nhỏ trước, rồi vừa, rồi lớn.
  static List<List<List<int>>> get all => [...small, ...medium, ...large];

  /// Hình thuộc nhóm lớn (so theo danh tính, vì mọi hình lấy từ danh mục).
  static bool isLarge(List<List<int>> shape) =>
      large.any((s) => identical(s, shape));
}
