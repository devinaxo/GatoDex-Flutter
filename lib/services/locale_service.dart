import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static const String _prefsKey = 'app_locale';
  static final LocaleService _instance = LocaleService._internal();

  factory LocaleService() => _instance;
  LocaleService._internal();

  // null means "follow system"
  Locale? _locale;
  Locale? get locale => _locale;

  bool get isSystemLocale => _locale == null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null && saved != 'system') {
      _locale = Locale(saved);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale? locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.setString(_prefsKey, 'system');
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}
