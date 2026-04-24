import 'dart:io';

import 'package:dartapi/constants/create_command_constants.dart';
import 'package:dartapi/dartapi.dart';

Future<void> createProject(
  String name, {
  Set<Feature> features = const {},
  bool full = false,
}) async {
  final effectiveFeatures = full ? kAllFeatures : features;

  print('Creating your new DartAPI project: $name');
  if (full) {
    print('Mode: --full (auth + db + files + ws)');
  } else if (effectiveFeatures.isNotEmpty) {
    print('Mode: --with=${effectiveFeatures.map((f) => f.name).join(',')}');
  } else {
    print('Mode: --minimal');
  }

  Process.runSync('dart', ['create', name]);

  // dart create generates bin/<name>.dart, lib/<name>.dart, and
  // test/<name>_test.dart — remove them so they don't conflict with our
  // templates.
  final stale = [
    '$name/bin/$name.dart',
    '$name/lib/$name.dart',
    '$name/test/${name}_test.dart',
  ];
  for (final path in stale) {
    final f = File(path);
    if (f.existsSync()) f.deleteSync();
  }

  for (final dir in CreateCommandConstants.directories(
    name,
    features: features,
    full: full,
  )) {
    Directory(dir).createSync(recursive: true);
    print('Directory: $dir created');
  }

  final fileMap = await CreateCommandConstants.files(
    name,
    features: features,
    full: full,
  );
  for (final file in fileMap.entries) {
    File(file.key).writeAsStringSync(file.value);
  }

  print('Running dart pub get...');
  final pubGet = await Process.run(
    'dart',
    ['pub', 'get'],
    workingDirectory: name,
  );
  if (pubGet.exitCode != 0) {
    print('Warning: dart pub get failed:\n${pubGet.stderr}');
  }

  print('******************************');
  print('DartAPI project $name created successfully!');
  print('******************************');
  print('  cd $name');
  print('  dartapi run --port=8080');
  if (effectiveFeatures.isNotEmpty) {
    print('');
    print('Endpoints:');
    print('  GET  /health  — health check');
    print('  GET  /hello   — hello world');
    if (effectiveFeatures.contains(Feature.auth)) {
      print('  POST /auth/login    — login (returns JWT)');
      print('  POST /auth/refresh  — refresh token');
      print('  POST /auth/logout   — revoke token');
    }
    if (effectiveFeatures.contains(Feature.db)) {
      print('  GET/POST /users      — list / create users');
      print('  GET/PUT/DELETE /users/<id>   — get / update / delete user');
      print('  GET/POST /products   — list / create products');
      print('  GET/PUT/DELETE /products/<id> — get / update / delete product');
    }
    if (effectiveFeatures.contains(Feature.files)) {
      print('  POST /files/upload  — upload a file (multipart)');
      print('  GET  /files         — list uploaded files');
    }
    if (effectiveFeatures.contains(Feature.ws)) {
      print('  ws://localhost:8080/ws/chat — WebSocket echo chat');
    }
  }
  print('******************************');
}
