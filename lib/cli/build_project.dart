import 'dart:io';

/// Compiles the current DartAPI project to a self-contained native executable
/// via `dart compile exe`.
///
/// Run from inside the project directory:
/// ```
/// dartapi build                    # produces ./server
/// dartapi build --output=myapp     # custom binary name
/// dartapi build --docker           # also writes a Dockerfile
/// ```
Future<void> buildProject({
  String output = 'server',
  bool docker = false,
}) async {
  final entrypoint = 'bin/main.dart';

  if (!File(entrypoint).existsSync()) {
    print('❌  $entrypoint not found. Run this command from your project root.');
    exit(1);
  }

  print('Building DartAPI project...');
  print('  dart compile exe $entrypoint -o $output');
  print('');

  final result = await Process.run(
    'dart',
    ['compile', 'exe', entrypoint, '-o', output],
  );

  if (result.stdout.toString().isNotEmpty) print(result.stdout);
  if (result.stderr.toString().isNotEmpty) print(result.stderr);

  if (result.exitCode != 0) {
    print('');
    print('❌  Build failed (exit code ${result.exitCode}).');
    exit(result.exitCode);
  }

  print('');
  print('******************************');
  print('Build successful → ./$output');
  print('Run with:  ./$output --port=8080');

  if (docker) {
    await _writeDockerfile(output);
    print('Dockerfile written → ./Dockerfile');
    print('Build image:  docker build -t my-app .');
    print('Run image:    docker run -p 8080:8080 my-app');
  }

  print('******************************');
}

Future<void> _writeDockerfile(String binary) async {
  const template = '''
# ── Stage 1: AOT compile ──────────────────────────────────────────────────────
FROM dart:stable AS builder

WORKDIR /app

# Cache pub dependencies before copying source
COPY pubspec.yaml pubspec.lock ./
RUN dart pub get

COPY . .
RUN dart compile exe bin/main.dart -o /app/server

# ── Stage 2: Minimal runtime image ────────────────────────────────────────────
FROM debian:bookworm-slim

WORKDIR /app

# Copy the compiled binary and any env files
COPY --from=builder /app/server /app/server
COPY --from=builder /app/env    /app/env

EXPOSE 8080

CMD ["/app/server", "--port=8080"]
''';

  await File('Dockerfile').writeAsString(template);
}
