import 'dart:async';
import 'dart:io';

void runServer({int port = 8080, bool watch = false}) async {
  Process? serverProcess;

  Future<void> startServer() async {
    print('Starting DartAPI server on port $port...');
    if (watch) print('Watch mode enabled — server restarts on file changes.');
    print('');

    serverProcess = await Process.start('dart', [
      'bin/main.dart',
      '--port',
      port.toString(),
    ], mode: ProcessStartMode.inheritStdio);

    print('');
    print('Type `r` to reload, `:q` to quit.');
    if (watch) print('Watching lib/ and bin/ for changes...');
    print('');
  }

  await startServer();

  if (watch) {
    final watched = <String>['lib', 'bin'];
    Timer? debounce;

    for (final dir in watched) {
      final d = Directory(dir);
      if (!d.existsSync()) continue;
      d.watch(recursive: true).listen((event) {
        if (!event.path.endsWith('.dart')) return;
        debounce?.cancel();
        debounce = Timer(const Duration(milliseconds: 500), () async {
          print('[watch] ${event.path} changed — reloading...');
          serverProcess?.kill(ProcessSignal.sigint);
          await serverProcess?.exitCode;
          await startServer();
        });
      });
    }
  }

  stdin.lineMode = true;
  stdin.echoMode = true;
  stdin.listen((input) async {
    final command = String.fromCharCodes(input).trim();

    if (command == ':q') {
      print('Stopping server...');
      serverProcess?.kill(ProcessSignal.sigint);
      await serverProcess?.exitCode;
      exit(0);
    }

    if (command == 'r') {
      print('Reloading server...');
      serverProcess?.kill(ProcessSignal.sigint);
      await serverProcess?.exitCode;
      await startServer();
    }
  });
}
