import 'dart:io';

import 'package:device_preview_screenshot/device_preview_screenshot.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

/// Take a screenshotボタンを押すとクリップボードに便利コマンドがコピーされる
Future<void> onScreenshot(
  BuildContext context,
  DeviceScreenshot screenshot,
) async {
  final isFrameVisible = context.read<DevicePreviewStore>().data.isFrameVisible;

  final timestamp = DateTime.now();
  final tempDir = await getTemporaryDirectory();
  final file =
      await File('${tempDir.path}/${screenshot.device.name}_$timestamp.png')
          .create();
  // フレームがあるときはそのまま書き込む
  if (isFrameVisible) {
    file.writeAsBytesSync(screenshot.bytes);
  }
  // フレームが無い時は実際の画面サイズに調整してから書き込む
  else {
    final rawImage = img.decodePng(screenshot.bytes);
    final resizedImage = img.copyResize(
      // ignore: avoid-non-null-assertion
      rawImage!,
      width: (screenshot.device.screenSize.width * screenshot.device.pixelRatio)
          .toInt(),
      height:
          (screenshot.device.screenSize.height * screenshot.device.pixelRatio)
              .toInt(),
    );
    file.writeAsBytesSync(img.encodePng(resizedImage));
  }

  // Finderでスクショがあるディレクトリを開くコマンドをクリップボードにセット
  // await Clipboard.setData(
  //   ClipboardData(text: 'open ${file.parent.path}'),
  // );
  // スクショがあるディレクトリのpngファイルをデスクトップに移動するコマンドをクリップボードにセット
  final message = 'mv ${file.parent.path}/*.png ~/Desktop';
  if (kDebugMode) {
    print(message);
  }
  await Clipboard.setData(
    ClipboardData(text: 'mv ${file.parent.path}/*.png ~/Desktop'),
  );
}
