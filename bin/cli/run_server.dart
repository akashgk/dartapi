import 'dart:io';

void runServer({int port = 8080}) async {
  print('🚀🚀🚀 Starting DartAPI server on Port: $port...');

  final process = await Process.start(
    'dart',
    ['bin/main.dart', '--port=$port'],
    mode: ProcessStartMode.inheritStdio,
  );

  await process.exitCode;
}
