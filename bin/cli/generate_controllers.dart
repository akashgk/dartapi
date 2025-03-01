import 'dart:io';

void generateController(String name) {
  final controllerFile = 'lib/src/controllers/${name.toLowerCase()}_controller.dart';

  final controllerContent = '''
import 'package:dartapi/dartapi.dart';

@Route('/${name.toLowerCase()}')
class ${name}Controller {
  @Get('/')
  Response getAll() {
    return Response.json({'message': '$name List'});
  }

  @Post('/')
  Response create(@Body() Map<String, dynamic> data) {
    return Response.json({'message': '$name Created', 'data': data});
  }
}
''';

  File(controllerFile).createSync(recursive: true);
  File(controllerFile).writeAsStringSync(controllerContent);
  
  print('✅ Controller $name created successfully at $controllerFile');
}