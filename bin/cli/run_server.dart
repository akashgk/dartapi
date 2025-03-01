import 'dart:io';

void runServer({int port = 8080}) {
  print('🚀🚀🚀 Starting DartAPI server on Port: $port...');
  Process.run('dart', ['bin/main.dart', '--port=$port']).then((result) {
    print(result.stdout);
    print(result.stderr);
  });
}
