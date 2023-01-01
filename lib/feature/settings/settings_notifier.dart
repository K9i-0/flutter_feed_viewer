import 'package:flutter/material.dart';
import 'package:flutter_feed_viewer/feature/settings/settings_repository.dart';
import 'package:flutter_feed_viewer/feature/settings/settings_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(ref),
);

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref _ref;
  SettingsNotifier(this._ref)
      : super(
          SettingsState(
              themeMode: _ref.read(settingsRepositoryProvider).themeMode),
        );

  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _ref.read(settingsRepositoryProvider).setThemeMode(themeMode);
    state = state.copyWith(themeMode: themeMode);
  }
}
