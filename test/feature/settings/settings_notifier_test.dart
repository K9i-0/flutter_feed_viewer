import 'package:flutter/material.dart';
import 'package:flutter_feed_viewer/feature/settings/settings_notifier.dart';
import 'package:flutter_feed_viewer/feature/settings/settings_repository.dart';
import 'package:flutter_feed_viewer/feature/settings/settings_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'settings_notifier_test.mocks.dart';

class Listener extends Mock {
  void call(SettingsState? previous, SettingsState value);
}

@GenerateMocks([SettingsRepository])
void main() {
  test('themeModeを更新できる', () async {
    final mockSettingsRepository = MockSettingsRepository();
    when(mockSettingsRepository.themeMode).thenReturn(ThemeMode.system);
    when(mockSettingsRepository.setThemeMode(ThemeMode.dark))
        .thenAnswer((_) async {});

    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(
          mockSettingsRepository,
        ),
      ],
    );
    addTearDown(container.dispose);
    final listener = Listener();
    container.listen(
      settingsProvider,
      listener,
      fireImmediately: true,
    );

    verify(listener(null, const SettingsState(themeMode: ThemeMode.system)))
        .called(1);
    verifyNoMoreInteractions(listener);

    await container
        .read(settingsProvider.notifier)
        .setThemeMode(ThemeMode.dark);

    verify(listener(
      const SettingsState(themeMode: ThemeMode.system),
      const SettingsState(themeMode: ThemeMode.dark),
    )).called(1);
    verifyNoMoreInteractions(listener);

    verify(mockSettingsRepository.setThemeMode(ThemeMode.dark)).called(1);
  });
}
