import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  static const String _themeModeKey = 'app_theme_mode';

  Locale _locale = const Locale('nl'); // Default to Dutch
  ThemeMode _themeMode = ThemeMode.system;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  AppSettings() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load language preference
    final languageCode = prefs.getString(_languageKey);
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }

    // Load theme preference
    final themeModeIndex = prefs.getInt(_themeModeKey);
    if (themeModeIndex != null) {
      _themeMode = ThemeMode.values[themeModeIndex];
    }

    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }
}
