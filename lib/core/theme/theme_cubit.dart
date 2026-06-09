import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences sharedPreferences;
  static const String _key = 'theme_mode';

  ThemeCubit({required this.sharedPreferences})
      : super(_loadTheme(sharedPreferences));

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final Object? value = prefs.get(_key);
    if (value is String) {
      switch (value) {
        case 'dark':
          return ThemeMode.dark;
        case 'light':
          return ThemeMode.light;
        default:
          return ThemeMode.dark;
      }
    } else if (value is int) {
      if (value >= 0 && value < ThemeMode.values.length) {
        return ThemeMode.values[value];
      }
    }
    return ThemeMode.dark;
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _save(newMode);
  }

  void setTheme(ThemeMode mode) => _save(mode);

  bool get isDark => state == ThemeMode.dark;

  void _save(ThemeMode mode) {
    emit(mode);
    sharedPreferences.setString(_key, mode.name);
  }
}
