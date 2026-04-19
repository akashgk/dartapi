import 'dart:io';

import 'package:dartapi/templates/template_engine.dart';
import 'package:dartapi/utils.dart';

Future<void> generateController(String name) async {
  final controllerFile =
      'lib/src/controllers/${name.toLowerCase()}_controller.dart';

  final content = await TemplateEngine.render('controller.dart.tmpl', {
    'ControllerName': name.capitalize(),
    'routePath': name.toLowerCase(),
  });

  File(controllerFile).createSync(recursive: true);
  File(controllerFile).writeAsStringSync(content);

  print('Controller ${name}Controller created at $controllerFile');
}
