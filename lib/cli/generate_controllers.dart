import 'dart:io';

import 'package:dartapi/utils.dart';

void generateController(String name) {
  final controllerFile =
      'lib/src/controllers/${name.toLowerCase()}_controller.dart';

  final controllerContent = '''
import 'package:dartapi_core/dartapi_core.dart';
import 'package:shelf/shelf.dart';

class ${name.capitalize()}Controller extends BaseController {
  @override
  List<ApiRoute> get routes => [
        ApiRoute<void, bool>(
          method: ApiMethod.get,
          path: '/${name.capitalize()}',
          typedHandler: getAll,
          summary: '',
          description: '< Insert description here >',
          requestSchema: {
            'type': 'object',
            'properties': {
              'name': {'type': 'string'},
              'age': {'type': 'integer'},
            },
            'required': ['name', 'age'],
            'example': {'name': 'John Doe', 'age': 30}
          },
          responseSchema: {
            'type': 'object',
            'properties': {
              'message': {'type': 'string'},
              'data': {'type': 'object'},
            },
            'required': ['message', 'data'],
            'example': {'message': 'Success', 'data': {}}
          },

        )
      ];


  Future<bool> getAll(Request request, void _) async {
    return true;
  }
}
''';

  File(controllerFile).createSync(recursive: true);
  File(controllerFile).writeAsStringSync(controllerContent);

  print(
    '✅ Controller ${name}Controller created successfully at $controllerFile',
  );
}
