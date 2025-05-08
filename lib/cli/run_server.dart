import 'dart:io';

void runServer({int port = 8080}) async {
  Process? serverProcess;

  Future<void> startServer() async {
    print('🚀 Starting DartAPI server on port $port...\n');

    serverProcess = await Process.start('dart', [
      'bin/main.dart',
      '--port',
      port.toString(),
    ], mode: ProcessStartMode.inheritStdio);

    print('🔧 Type `:q` to quit, `r` to reload\n');
  }

  await startServer();

  stdin.lineMode = true;
  stdin.echoMode = true;
  stdin.listen((input) async {
    final command = String.fromCharCodes(input).trim();

    if (command == ':q') {
      print('🛑 Quitting server...');
      serverProcess?.kill(ProcessSignal.sigint);
      await serverProcess?.exitCode;
      exit(0);
    }

    if (command == 'r') {
      print('🔄 Reloading server...\n');
      serverProcess?.kill(ProcessSignal.sigint);
      await serverProcess?.exitCode;
      await startServer();
    }
  });
}
