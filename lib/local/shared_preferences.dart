import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

enum SharedPreferencesKeys {
  themeMode('themeMode');

  final String value;
  const SharedPreferencesKeys(this.value);
}
