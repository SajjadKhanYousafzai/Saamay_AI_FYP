import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeType {
  saamayDark,
  white,
  natureGreen,
  freezedIce,
  royalPurple,
}

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  AppThemeType _currentTheme = AppThemeType.saamayDark;

  ThemeMode get themeMode {
    switch (_currentTheme) {
      case AppThemeType.saamayDark:
        return ThemeMode.dark;
      case AppThemeType.white:
        return ThemeMode.light;
      case AppThemeType.natureGreen:
        return ThemeMode.dark;
      case AppThemeType.freezedIce:
        return ThemeMode.dark;
      case AppThemeType.royalPurple:
        return ThemeMode.dark;
    }
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;
  AppThemeType get currentTheme => _currentTheme;

  String get currentThemeName {
    switch (_currentTheme) {
      case AppThemeType.saamayDark:
        return 'Saamay Dark';
      case AppThemeType.white:
        return 'White';
      case AppThemeType.natureGreen:
        return 'Nature Green';
      case AppThemeType.freezedIce:
        return 'Freezed Ice';
      case AppThemeType.royalPurple:
        return 'Royal Purple';
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(_themeKey) ?? 'saamayDark';
    _currentTheme = AppThemeType.values.firstWhere(
      (e) => e.name == themeStr,
      orElse: () => AppThemeType.saamayDark,
    );
    notifyListeners();
  }

  Future<void> setTheme(AppThemeType theme) async {
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.name);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (isDarkMode) {
      await setTheme(AppThemeType.white);
    } else {
      await setTheme(AppThemeType.saamayDark);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == ThemeMode.light) {
      await setTheme(AppThemeType.white);
    } else {
      await setTheme(AppThemeType.saamayDark);
    }
  }
}
