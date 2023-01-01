# flutter_feed_viewer

Flutterの最新記事を閲覧するサンプルアプリです。

Riverpodを使ったFlutterアプリの例として参考にしてもらえると嬉しいです。

コメントやプルリクエストなど、できるだけ日本語で書いています。

<p align="center">
  <img src="https://raw.githubusercontent.com/K9i-0/flutter_feed_viewer/main/flutter_feed_viewer.gif" alt="flutter_feed_viewer" />
</p>


# 使い方

### Android, iOSの場合
このリポジトリをクローンすれば、カウンターサンプルと同じ容量で動かせるはずです。

### Webの場合
フィード取得でエラーになるので、Webで動かす際は後述のgrinderでCORSを無効化してください。

### grinder
コマンドラインからDartタスクを実行できるgrinderを導入しています。
詳しくはtoolディレクトリのREADME.mdを参照してください。

https://github.com/K9i-0/flutter_feed_viewer/tree/develop/tool

### device_preview
device_previewおよびdevice_preview_screenshotを導入しています。

解説記事
https://zenn.dev/k9i/articles/69eb5a52ce16d1

--dart-define=enable_device_preview=trueを指定して起動すると有効になります。


# ディレクトリ構成
lib以下は以下のような構成です。
構成はRiverpodの公式サンプルや以下の記事を参考にしています。
https://medium.com/flutter-jp/architecture-240d3c56b597

```
lib
├── common_widget
├── feature
│   ├── feed
│   │   └── ui
│   └── settings
├── local
├── main.dart
└── util
```
### common_widget
汎用Widgetが入るディレクトリです。

### feature
機能をまとめたディレクトリです。
feedディレクトリならフィードの機能のUI、ロジック、リポジトリがまとまっています。

uiディレクトリは画面が複雑な場合に、クラスとして切り出されたWidgetをまとめています。

### local
ローカルデータソースが入るディレクトリです。
現在はSharedPreferencesのキーやSharedPreferencesのProviderが入っているほか、データベースの定義などもここに入ります。

### util
extensionやhelperが入っています。