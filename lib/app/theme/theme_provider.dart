import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/providers/auth_provider.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences prefs;
  static const String _themeKey = 'user_theme_mode';

  ThemeNotifier({required this.prefs}) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final savedMode = prefs.getString(_themeKey);
    if (savedMode == 'dark') {
      state = ThemeMode.dark;
    } else if (savedMode == 'light') {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    if (mode == ThemeMode.dark) {
      await prefs.setString(_themeKey, 'dark');
    } else if (mode == ThemeMode.light) {
      await prefs.setString(_themeKey, 'light');
    } else {
      await prefs.remove(_themeKey);
    }
  }

  Future<void> toggleDarkLight() async {
    if (state == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(
    prefs: ref.watch(sharedPreferencesProvider),
  );
});
