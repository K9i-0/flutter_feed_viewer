# flutter_feed_viewer

Flutterの最新記事を閲覧するサンプルアプリです。

コメントやプルリクエストなど日本語にしています。

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
feed/uiは画面が複雑な場合に、Widgetをクラスとして切り出したものをまとめています。

### local
ローカルデータソースが入るディレクトリです。
現在はSharedPreferencesのキーやSharedPreferencesのProviderが入っているほか、データベースの定義などもここに入ります。

### util
extensionやhelperが入っています。