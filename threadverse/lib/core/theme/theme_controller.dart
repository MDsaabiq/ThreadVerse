import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Riverpod controller to manage theme mode and AMOLED preference with persistence.
final themeControllerProvider = NotifierProvider<ThemeController, ThemeState>(
  ThemeController.new,
);

class ThemeState {
  const ThemeState({
    required this.themeMode,
    required this.useAmoled,
  });

  final ThemeMode themeMode;
  final bool useAmoled;

  ThemeState copyWith({ThemeMode? themeMode, bool? useAmoled}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      useAmoled: useAmoled ?? this.useAmoled,
    );
  }
}

class ThemeController extends Notifier<ThemeState> {
  static const _prefsThemeModeKey = 'theme_mode';
  static const _prefsAmoledKey = 'theme_amoled';

  @override
  ThemeState build() {
    // Initialize with system theme; persistence will load asynchronously.
    _loadFromPrefs();
    return const ThemeState(themeMode: ThemeMode.system, useAmoled: false);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsThemeModeKey, _encodeMode(mode));
  }

  Future<void> setAmoled(bool enabled) async {
    state = state.copyWith(useAmoled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsAmoledKey, enabled);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMode = prefs.getString(_prefsThemeModeKey);
    final storedAmoled = prefs.getBool(_prefsAmoledKey);

    state = state.copyWith(
      themeMode: _decodeMode(storedMode) ?? state.themeMode,
      useAmoled: storedAmoled ?? state.useAmoled,
    );
  }

  String _encodeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }

  ThemeMode? _decodeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }
}
