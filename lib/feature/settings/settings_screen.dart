import 'package:flutter/material.dart';
import 'package:flutter_feed_viewer/feature/settings/settings_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        children: [
          // テーマの切り替え
          ListTile(
            title: const Text('テーマ'),
            trailing: DropdownButton<ThemeMode>(
              value: ref
                  .watch(settingsProvider.select((value) => value.themeMode)),
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).setThemeMode(value);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('端末の設定を使う'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('ライト'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('ダーク'),
                ),
              ],
            ),
          ),
          // OOSライセンス
          ListTile(
            title: const Text('OOSライセンス'),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Flutter Feed Viewer',
                applicationVersion: '1.0.0',
                applicationIcon: const SizedBox(
                  width: 48,
                  height: 48,
                  child: FlutterLogo(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
