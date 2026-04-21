import 'dart:io';

import 'package:dartapi/templates/template_engine.dart';
import 'package:dartapi/utils.dart';

Future<void> generateResource(String name) async {
  final resourceName = name.capitalize();
  final resourcePath = name.toLowerCase();

  final vars = {
    'ResourceName': resourceName,
    'resourcePath': resourcePath,
  };

  final files = {
    'lib/src/controllers/${resourcePath}_controller.dart':
        'resource_controller.dart.tmpl',
    'lib/src/dto/${resourcePath}_dto.dart': 'resource_dto.dart.tmpl',
    'lib/src/models/$resourcePath.dart': 'resource_model.dart.tmpl',
  };

  for (final entry in files.entries) {
    final content = await TemplateEngine.render(entry.value, vars);
    File(entry.key).createSync(recursive: true);
    File(entry.key).writeAsStringSync(content);
  }

  print('Resource $resourceName scaffolded:');
  for (final path in files.keys) {
    print('  $path');
  }
  print('');
  print('Next steps:');
  print(
    '  1. Add your fields to lib/src/models/$resourcePath.dart and lib/src/dto/${resourcePath}_dto.dart',
  );
  print(
    '  2. Generate a migration: dartapi generate migration create_${resourcePath}s_table',
  );
  print('  3. Register in bin/main.dart:');
  print('');
  print(
    "     import 'package:<your_project>/src/controllers/${resourcePath}_controller.dart';",
  );
  print('');
  print('     app.addControllers([');
  print('       ...,');
  print('       ${resourceName}Controller(db),');
  print('     ]);');
}
