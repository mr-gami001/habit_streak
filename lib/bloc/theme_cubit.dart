import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String settingsBoxName = 'settings_box';
  static const String themeKey = 'theme_mode';

  ThemeCubit() : super(ThemeMode.dark) {
    _loadThemeFromSettings();
  }

  Future<void> _loadThemeFromSettings() async {
    try {
      final box = await Hive.openBox(settingsBoxName);
      final savedThemeString = box.get(themeKey, defaultValue: 'dark') as String;
      if (savedThemeString == 'light') {
        emit(ThemeMode.light);
      } else if (savedThemeString == 'dark') {
        emit(ThemeMode.dark);
      } else {
        emit(ThemeMode.system);
      }
    } catch (_) {
      emit(ThemeMode.dark);
    }
  }

  Future<void> toggleTheme() async {
    final nextTheme = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(nextTheme);
    try {
      final box = await Hive.openBox(settingsBoxName);
      await box.put(themeKey, nextTheme == ThemeMode.light ? 'light' : 'dark');
    } catch (_) {}
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    emit(themeMode);
    try {
      final box = await Hive.openBox(settingsBoxName);
      String val = 'system';
      if (themeMode == ThemeMode.light) val = 'light';
      if (themeMode == ThemeMode.dark) val = 'dark';
      await box.put(themeKey, val);
    } catch (_) {}
  }
}
