import 'dart:io';

import 'package:dartapi/dartapi.dart';

void createProject(String name) {
  print('📦 Creating your New DartAPI project: $name');

  // ✅ Create a Dart application (not a library)
  Process.runSync('dart', ['create', name]);

  for (var dir in CreateCommandConstants.directories(name)) {
    Directory(dir).createSync(recursive: true);
    print('Directory: $dir created ✅');
  }

  for (var file in CreateCommandConstants.files(name).entries) {
    File(file.key).writeAsStringSync(file.value);
  }

  print('******************************');
  print('🚀 DartAPI project $name created successfully! 🚀');
  print('******************************');
  print('📌 cd $name');
  print('📌 dart pub get');
  print('📌 dartapi run --port=8080');
  print('******************************');
}
