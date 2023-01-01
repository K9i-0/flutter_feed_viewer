import 'package:flutter/material.dart';

// TextThemeやColorSchemeを楽に取得するための拡張メソッド
extension BuildContextX on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
