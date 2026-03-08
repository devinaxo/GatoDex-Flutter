import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system, materialYou }

class ThemeService extends ChangeNotifier {
  static const String _prefsKey = 'theme_mode';
  static final ThemeService _instance = ThemeService._internal();

  factory ThemeService() => _instance;
  ThemeService._internal();

  AppThemeMode _currentMode = AppThemeMode.materialYou;
  AppThemeMode get currentMode => _currentMode;

  bool get useDynamicColor => _currentMode == AppThemeMode.materialYou;

  ThemeMode get themeMode {
    switch (_currentMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
      case AppThemeMode.materialYou:
        return ThemeMode.system;
    }
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      _currentMode = AppThemeMode.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => AppThemeMode.materialYou,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_currentMode == mode) return;
    _currentMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }
}
