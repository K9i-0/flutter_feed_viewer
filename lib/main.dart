import 'package:device_preview_screenshot/device_preview_screenshot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feed_viewer/feature/feed/feed_screen.dart';
import 'package:flutter_feed_viewer/util/device_preview_screenshot_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
      home: const FeedScreen(),
    );
  }
}
