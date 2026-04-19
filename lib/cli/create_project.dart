import 'dart:io';

import 'package:dartapi/dartapi.dart';

Future<void> createProject(String name) async {
  print('Creating your new DartAPI project: $name');

  Process.runSync('dart', ['create', name]);

  // dart create generates bin/<name>.dart and lib/<name>.dart — remove them
  // so they don't conflict with our templates (bin/main.dart etc.)
  final stale = [
    '$name/bin/$name.dart',
    '$name/lib/$name.dart',
  ];
  for (final path in stale) {
    final f = File(path);
    if (f.existsSync()) f.deleteSync();
  }

  for (var dir in CreateCommandConstants.directories(name)) {
    Directory(dir).createSync(recursive: true);
    print('Directory: $dir created');
  }

  final fileMap = await CreateCommandConstants.files(name);
  for (var file in fileMap.entries) {
    File(file.key).writeAsStringSync(file.value);
  }

  print('******************************');
  print('DartAPI project $name created successfully!');
  print('******************************');
  print('  cd $name');
  print('  dart pub get');
  print('  dartapi run --port=8080');
  print('******************************');
}
