import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';

enum ThemeType { dark, light, purple, blue, system }

class ThemeNotifier extends Notifier<ThemeData> {
  ThemeType _currentThemeType = ThemeType.dark;

  @override
  ThemeData build() {
    _loadTheme();
    return _getThemeData(_currentThemeType);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme') ?? 0;
    _currentThemeType = ThemeType.values[themeIndex];
    state = _getThemeData(_currentThemeType);
  }

  Future<void> setTheme(ThemeType themeType) async {
    _currentThemeType = themeType;
    state = _getThemeData(themeType);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme', themeType.index);
  }

  ThemeData _getThemeData(ThemeType themeType) {
    switch (themeType) {
      case ThemeType.dark:
        return AppTheme.darkTheme;
      case ThemeType.light:
        return AppTheme.lightTheme;
      case ThemeType.purple:
        return AppTheme.purpleTheme;
      case ThemeType.blue:
        return AppTheme.blueTheme;
      case ThemeType.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
            ? AppTheme.darkTheme
            : AppTheme.lightTheme;
    }
  }

  ThemeType get currentThemeType => _currentThemeType;
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeData>(() {
  return ThemeNotifier();
});

final currentThemeTypeProvider = Provider<ThemeType>((ref) {
  return ref.watch(themeProvider.notifier).currentThemeType;
});