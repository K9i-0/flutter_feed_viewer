import 'package:flutter/material.dart';
import 'package:flutter_feed_viewer/local/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final settingsRepositoryProvider = Provider.autoDispose<SettingsRepository>(
  (ref) => SettingsRepository(ref),
);

class SettingsRepository {
  final Ref _ref;
  const SettingsRepository(this._ref);

  ThemeMode get themeMode {
    final themeModeIndex = _ref
        .read(sharedPreferencesProvider)
        .getInt(SharedPreferencesKeys.themeMode.name);

    if (themeModeIndex == null) {
      return ThemeMode.system;
    }
    return ThemeMode.values[themeModeIndex];
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _ref
        .read(sharedPreferencesProvider)
        .setInt(SharedPreferencesKeys.themeMode.name, themeMode.index);
  }
}
