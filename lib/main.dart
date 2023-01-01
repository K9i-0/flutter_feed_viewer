import 'package:device_preview_screenshot/device_preview_screenshot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feed_viewer/feature/feed/feed_screen.dart';
import 'package:flutter_feed_viewer/feature/settings/settings_notifier.dart';
import 'package:flutter_feed_viewer/feature/settings/settings_screen.dart';
import 'package:flutter_feed_viewer/local/shared_preferences.dart';
import 'package:flutter_feed_viewer/util/device_preview_screenshot_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: DevicePreview(
        enabled: const bool.fromEnvironment('enable_device_preview'),
        tools: const [
          ...DevicePreview.defaultTools,
          DevicePreviewScreenshot(
            onScreenshot: onScreenshot,
          ),
        ],
        builder: (context) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter最新記事',
      // useInheritedMediaQuery、locale、builderは、DevicePreviewに必要
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        // TODO(K9i-0): TabBarのM3対応がstableに入ったらuseMaterial3: trueに変える
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: ref.watch(settingsProvider.select((value) => value.themeMode)),
      home: const FeedScreen(),
      routes: {
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
