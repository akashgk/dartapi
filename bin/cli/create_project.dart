import 'dart:io';

void createProject(String name) {
  print('📦 Creating DartAPI project: $name');

  // ✅ Create a Dart application (not a library)
  Process.runSync('dart', ['create', name]);

  final directories = [
    '$name/lib/src/core',
    '$name/lib/src/controllers',
    '$name/lib/src/models',
    '$name/lib/src/middleware',
    '$name/lib/src/db',
    '$name/bin',
    '$name/test',
  ];

  final files = {
    // ✅ **Main entry point**
    '$name/bin/main.dart': '''
import 'package:$name/src/core/server.dart';
import 'package:$name/src/controllers/user_controller.dart';

void main(List<String> args) {
  int port = 8080; // Default port

  // Parse command-line arguments for port
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--port' && i + 1 < args.length) {
      port = int.tryParse(args[i + 1]) ?? 8080;
      break;
    }
  }

  final app = DartAPI();
  app.addControllers([UserController()]);
  app.start(port: port);
}
''',

    // ✅ **pubspec.yaml**
    '$name/pubspec.yaml': '''
name: $name
description: A FastAPI-like framework for Dart.
version: 0.1.0
environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  shelf: ^1.4.0
  shelf_router: ^1.1.3

dev_dependencies:
  test: ^1.22.0
  lints: ^5.1.1
''',

    // ✅ **Analysis Options (Fixes `lints/recommended.yaml` issue)**
    '$name/analysis_options.yaml': '''
include: package:lints/recommended.yaml
''',

    // ✅ **Core Server File**
    '$name/lib/src/core/server.dart': '''
import 'package:$name/src/middleware/logging.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf/shelf.dart';
import 'router.dart';
import 'package:$name/src/controllers/base_controller.dart';

class DartAPI {
  final RouterManager _router = RouterManager();

  Future<void> start({int port = 8080}) async {
    final handler = Pipeline()
        .addMiddleware(loggingMiddleware()) 
        .addHandler(_router.handler.call);

    await io.serve(handler, '0.0.0.0', port);
    print('🚀 Server running on http://localhost:\$port');
  }

  void addControllers(List<BaseController> controllers) {
    for (var controller in controllers) {
      _router.registerController(controller);
    }
  }
}
''',

    // ✅ **Router File**
    '$name/lib/src/core/router.dart': '''
import 'package:shelf_router/shelf_router.dart';
import '../controllers/base_controller.dart';

class RouterManager {
  final Router _router = Router();

  Router get handler => _router;

  void registerController(BaseController controller) {
    for (var route in controller.routes) {
      _router.add(route.method, route.path, route.handler);
    }
  }
}
''',

    // ✅ **Base Controller (Fixes `BaseController` Not Found Issue)**
    '$name/lib/src/controllers/base_controller.dart': '''
import 'package:shelf/shelf.dart';

abstract class BaseController {
  List<RouteDefinition> get routes;
}

class RouteDefinition {
  final String method;
  final String path;
  final Handler handler;

  RouteDefinition(this.method, this.path, this.handler);
}
''',

    // ✅ **User Controller (Example)**
    '$name/lib/src/controllers/user_controller.dart': '''
import 'package:shelf/shelf.dart';
import 'base_controller.dart';

class UserController extends BaseController {
  @override
  List<RouteDefinition> get routes => [
        RouteDefinition('GET', '/users', getAllUsers),
        RouteDefinition('POST', '/users', createUser),
      ];

  Response getAllUsers(Request request) {
    return Response.ok('{"users": ["Christy", "Akash"]}', headers: {'Content-Type': 'application/json'});
  }

  Response createUser(Request request) {
    return Response.ok('{"message": "User created"}', headers: {'Content-Type': 'application/json'});
  }
}
''',

    // ✅ **Middleware (for logging, auth, etc.)**
    '$name/lib/src/middleware/logging.dart': '''
import 'package:shelf/shelf.dart';

Middleware loggingMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      print("📌 Request: \${request.method} \${request.requestedUri}");
      final response = await innerHandler(request);
      return response;
    };
  };
}
''',

    // ✅ **Database File (Dummy for Expansion)**
    '$name/lib/src/db/database.dart': '''
class Database {
  static void connect() {
    print('🔗 Connecting to database...');
  }
}
''',
  };

  // ✅ **Create directories**
  for (var dir in directories) {
    Directory(dir).createSync(recursive: true);
  }

  // ✅ **Create files**
  for (var file in files.entries) {
    File(file.key).writeAsStringSync(file.value);
  }

  print('🚀 DartAPI project $name created successfully! 🚀');
  print('******************************');
  print('📌 cd $name');
  print('📌 dart pub get');
  print('📌 dartapi run --port=8080');
  print('******************************');

}