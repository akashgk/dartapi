import 'dart:io';

void generateController(String name) {
  final controllerFile = 'lib/src/controllers/${name.toLowerCase()}_controller.dart';

  final controllerContent = '''
import 'package:shelf/shelf.dart';
import 'base_controller.dart';

class ${name}Controller extends BaseController {
  @override
  List<RouteDefinition> get routes => [
        RouteDefinition('GET', '/${name.toLowerCase()}', getAll),
        RouteDefinition('POST', '/${name.toLowerCase()}', create),
      ];

  Response getAll(Request request) {
    return Response.ok('{"message": "$name List"}', headers: {'Content-Type': 'application/json'});
  }

  Future<Response> create(Request request) async {
    final body = await request.readAsString();
    return Response.ok('{"message": "$name Created", "data": \$body}', headers: {'Content-Type': 'application/json'});
  }
}
''';

  File(controllerFile).createSync(recursive: true);
  File(controllerFile).writeAsStringSync(controllerContent);

  print('✅ Controller ${name}Controller created successfully at $controllerFile');
}