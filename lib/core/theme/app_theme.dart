import 'package:flutter/material.dart';

import '../constants/colors.dart';
import 'app_typography.dart';

/// Theme Material của app, dùng font đóng gói (không tải font lúc chạy).
class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    fontFamily: AppTypography.bodyFamily,
    textTheme: ThemeData.dark().textTheme
        .apply(fontFamily: AppTypography.bodyFamily)
        .copyWith(
          headlineLarge: AppTypography.display(),
          headlineMedium: AppTypography.headline(),
          bodyLarge: AppTypography.body(size: 18),
          bodyMedium: AppTypography.body(color: Colors.white70),
        ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: AppColors.primary.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: AppTypography.title(),
      ),
    ),
  );
}
