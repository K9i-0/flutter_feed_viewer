import 'dart:io';

import 'package:grinder/grinder.dart';

void main(List<String> args) => grind(args);

Future<void> _runCommand({
  required String command,
}) async {
  final splittedCommand = command.split(' ');
  log(command);
  final process = await Process.start(
    splittedCommand.first,
    splittedCommand.sublist(1),
  );
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
}

@Task('flutter pub run build_runner build --delete-conflicting-outputs')
void g() {
  _runCommand(command: 'flutter pub run build_runner build -d');
}

/// Flutter Webでエラーになるので、CORSを無効にする
/// 事前にdart pub global activate flutter_corsを実行する必要がある
///
/// 詳細 https://pub.dev/packages/flutter_cors
@Task('fluttercors --disable')
void cd() {
  _runCommand(command: 'fluttercors -d');
}

@Task('fluttercors --enable')
void ce() {
  _runCommand(command: 'fluttercors -e');
}
