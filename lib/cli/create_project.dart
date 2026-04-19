import 'dart:io';

import 'package:dartapi/dartapi.dart';

Future<void> createProject(String name) async {
  print('Creating your new DartAPI project: $name');

  Process.runSync('dart', ['create', name]);

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
