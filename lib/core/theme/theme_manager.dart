import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';

enum AppThemeType {
  neon,
  wood,
  jewel,
}

class ThemeManager extends ChangeNotifier {
  AppThemeType _currentTheme = AppThemeType.neon;

  AppThemeType get currentTheme => _currentTheme;

  ThemeManager() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_index') ?? 0;
    if (themeIndex >= 0 && themeIndex < AppThemeType.values.length) {
      _currentTheme = AppThemeType.values[themeIndex];
      notifyListeners();
    }
  }

  Future<void> setTheme(AppThemeType type) async {
    _currentTheme = type;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_index', type.index);
  }

  // --- Dynamic Theme Values ---
  
  List<Color> get backgroundGradient {
    switch (_currentTheme) {
      case AppThemeType.neon:
        return [AppColors.backgroundStart, AppColors.backgroundMiddle, AppColors.backgroundEnd];
      case AppThemeType.wood:
        return [const Color(0xFF4A3B2C), const Color(0xFF2E2218), const Color(0xFF1E1610)];
      case AppThemeType.jewel:
        return [const Color(0xFF140D2B), const Color(0xFF281142), const Color(0xFF0F0B1E)];
    }
  }

  Color get boardBackground {
    switch (_currentTheme) {
      case AppThemeType.neon:
        return AppColors.boardBackground;
      case AppThemeType.wood:
        return const Color(0x665C4033);
      case AppThemeType.jewel:
        return const Color(0x22FFFFFF);
    }
  }
}
