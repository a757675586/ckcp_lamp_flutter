import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// State model
class PreferencesState {
  final ThemeMode themeMode;
  final Locale locale;

  PreferencesState({
    required this.themeMode,
    required this.locale,
  });

  PreferencesState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return PreferencesState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

// Notifier
class PreferencesNotifier extends StateNotifier<PreferencesState> {
  PreferencesNotifier()
      : super(PreferencesState(
            themeMode: ThemeMode.system, locale: const Locale('zh')));

  static const _keyTheme = 'preferences_theme';
  static const _keyLocale = 'preferences_locale';

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Theme
    final themeStr = prefs.getString(_keyTheme) ?? 'system';
    final themeMode = _parseThemeMode(themeStr);

    // Load Locale
    final localeStr = prefs.getString(_keyLocale) ?? 'zh';
    final locale = Locale(localeStr);

    state = PreferencesState(themeMode: themeMode, locale: locale);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTheme, mode.name); // 'system', 'light', 'dark'
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale.languageCode);
  }

  ThemeMode _parseThemeMode(String str) {
    switch (str) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

// Provider
final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, PreferencesState>((ref) {
  final notifier = PreferencesNotifier();
  notifier.loadPreferences();
  return notifier;
});
