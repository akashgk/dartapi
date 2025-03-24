import 'dart:io';

void createProject(String name) {
  print('📦 Creating your New DartAPI project: $name');

  // ✅ Create a Dart application (not a library)
  Process.runSync('dart', ['create', name]);

  final directories = [
    '$name/lib/src/core',
    '$name/lib/src/controllers',
    '$name/lib/src/models',
    '$name/lib/src/middleware',
    '$name/lib/src/db',
    '$name/lib/src/dto',
    '$name/lib/src/utils',
    '$name/bin',
    '$name/test',
  ];

  final files = {
    '$name/bin/main.dart': '''
import 'package:$name/src/core/server.dart';
import 'package:$name/src/controllers/user_controller.dart';
import 'package:$name/src/controllers/auth_controller.dart';

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
  app.addControllers([
    UserController(app.jwtService),
    AuthController(app.jwtService),
  ]);
  app.start(port: port);
}
''',

    '$name/pubspec.yaml': '''
name: $name
description: A FastAPI-like framework for Dart.
version: 0.1.0
environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  dartapi_auth: ^0.0.1
  shelf: ^1.4.0
  shelf_cors_headers: ^0.1.5
  shelf_router: ^1.1.3

dev_dependencies:
  test: ^1.22.0
  lints: ^5.1.1
''',

    '$name/analysis_options.yaml': '''
include: package:lints/recommended.yaml
''',

    '$name/lib/src/core/server.dart': '''
import 'package:dartapi_auth/dartapi_auth.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'package:$name/src/controllers/base_controller.dart';
import 'package:$name/src/middleware/logging.dart';

import 'router.dart';

class DartAPI {
  final RouterManager _router = RouterManager();

  final jwtService = JwtService(
    accessTokenSecret: 'super-secret-key',
    refreshTokenSecret: 'super-refresh-secret',
    issuer: 'dartapi',
    audience: 'dartapi-users',
  );

  Future<void> start({int port = 8080}) async {
    final handler = Pipeline()
        .addMiddleware(loggingMiddleware())
        .addMiddleware(corsHeaders(
          headers: {
            ACCESS_CONTROL_ALLOW_ORIGIN: '*',
            ACCESS_CONTROL_ALLOW_METHODS: 'GET, POST, PUT, DELETE, OPTIONS',
            ACCESS_CONTROL_ALLOW_HEADERS: '*',
          },
        ))
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

    '$name/lib/src/core/router.dart': '''
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:$name/src/controllers/base_controller.dart';
import 'package:$name/src/middleware/request_validation.dart';


class RouterManager {
  final Router _router = Router();

  Router get handler => _router;

  void registerController(BaseController controller) {
    for (RouteDefinition route in controller.routes) {
      Handler finalHandler = route.handler;

      if (route.dtoParser != null) {
        final Middleware middleware =
            validateRequestMiddleware(route.dtoParser!);
        finalHandler = middleware(route.handler);
      }

      for (Middleware routeMiddleWare in route.middlewares) {
        finalHandler = routeMiddleWare(finalHandler);
      }

      _router.add(route.method, route.path, finalHandler);
    }
  }
}

''',

    '$name/lib/src/controllers/base_controller.dart': '''
import 'package:shelf/shelf.dart';

abstract class BaseController {
  List<RouteDefinition> get routes;
}


class RouteDefinition<T> {
  final String method;
  final String path;
  final Handler handler;
  final T Function(String?)? dtoParser;
  final List<Middleware> middlewares;

  RouteDefinition(
    this.method,
    this.path,
    this.handler, {
    this.dtoParser,
    this.middlewares = const [],
  });
}

''',
    '$name/lib/src/controllers/auth_controller.dart': '''
import 'package:$name/src/dto/login_dto.dart';
import 'package:dartapi_auth/dartapi_auth.dart';
import 'package:shelf/shelf.dart';
import 'base_controller.dart';

class AuthController extends BaseController {
  final JwtService jwtService;

  AuthController(this.jwtService);

  @override
  List<RouteDefinition> get routes => [
        RouteDefinition(
          'POST',
          '/auth/login',
          login,
          dtoParser: (data) => LoginDTO.fromJson(data!),
        ),
        RouteDefinition('POST', '/auth/refresh', refreshToken),
      ];

  Future<Response> login(Request request) async {
    final dto = request.context['dto'] as LoginDTO;

    if (dto.username == 'admin' && dto.password == '1234') {
      final accessToken = jwtService.generateAccessToken(claims: {
        'sub': 'user-123',
        'username': dto.username,
      });

      final refreshToken =
          jwtService.generateRefreshToken(accessToken: accessToken);

      return Response.ok(
          '{"access_token": "\$accessToken", "refresh_token": "\$refreshToken"}',
          headers: {'Content-Type': 'application/json'});
    }

    return Response.forbidden('{"error": "Invalid credentials"}',
        headers: {'Content-Type': 'application/json'});
  }

  Future<Response> refreshToken(Request request) async {
    final body = await request.readAsString();
    final data = Uri.splitQueryString(body);

    final refreshToken = data['refresh_token'];
    if (refreshToken == null) {
      return Response.forbidden('{"error": "Missing refresh token"}',
          headers: {'Content-Type': 'application/json'});
    }

    final payload = jwtService.verifyRefreshToken(refreshToken);
    if (payload == null) {
      return Response.forbidden('{"error": "Invalid or expired refresh token"}',
          headers: {'Content-Type': 'application/json'});
    }

    final newAccessToken = jwtService.generateAccessToken(claims: {
      'sub': payload['sub'],
      'username': payload['username'],
    });

    return Response.ok('{"access_token": "\$newAccessToken"}',
        headers: {'Content-Type': 'application/json'});
  }

}

''',

    '$name/lib/src/controllers/user_controller.dart': '''
import 'dart:convert';
import 'package:dartapi_auth/dartapi_auth.dart';


import 'package:$name/src/dto/user_dto.dart';
import 'package:shelf/shelf.dart';
import 'base_controller.dart';

class UserController extends BaseController {
  final JwtService jwtService;

  UserController(this.jwtService);

  @override
  List<RouteDefinition> get routes => [
        RouteDefinition('GET', '/users', getAllUsers,
            middlewares: [authMiddleware(jwtService)]),
        RouteDefinition<UserDTO>(
          'POST',
          '/users',
          createUser,
          dtoParser: (jsonString) => UserDTO.fromJson(jsonString!),
        ),
      ];

  Response getAllUsers(Request request) {
    return Response.ok('{"users": ["Christy", "Akash"]}',
        headers: {'Content-Type': 'application/json'});
  }

  Future<Response> createUser(Request request) async {
    final dto = request.context['dto'] as UserDTO;

    return Response.ok(jsonEncode({'message': 'User \${dto.name} created'}),
        headers: {'Content-Type': 'application/json'});
  }
}
''',

    '$name/lib/src/db/database.dart': '''
class Database {
  static void connect() {
    print('🔗 Connecting to database...');
  }
}
''',

    '$name/lib/src/dto/user_dto.dart': '''
import 'dart:convert';

import 'package:$name/src/utils/utils.dart';

class UserDTO {
  final String name;
  final int age;
  final String email;

  UserDTO({required this.name, required this.age, required this.email});

  factory UserDTO.fromJson(String jsonStr) {
    final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;

    return UserDTO(
      name: jsonData.verifyKey<String>('name'),
      age: jsonData.verifyKey<int>('age'),
      email: jsonData.verifyKey<String>('email'),
    );
  }
}

''',

    '$name/lib/src/dto/login_dto.dart': '''
import 'dart:convert';

import 'package:$name/src/utils/utils.dart';

class LoginDTO {
  final String username;
  final String password;

  LoginDTO({required this.username, required this.password});

  factory LoginDTO.fromJson(String jsonStr) {
    final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;

    return LoginDTO(
      username: jsonData.verifyKey<String>('username'),
      password: jsonData.verifyKey<String>('password'),
    );
  }
}

''',

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

    '$name/lib/src/middleware/request_validation.dart': '''
import 'dart:convert';

import 'package:shelf/shelf.dart';

Middleware validateRequestMiddleware<T>(T Function(String) parser) {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        final body = await request.readAsString();
        final dto = parser(body);
        request = request.change(context: {'dto': dto});
        return innerHandler(request);
      } catch (e) {
        return Response.badRequest(
            body: jsonEncode({'error': e.toString()}),
            headers: {'Content-Type': 'application/json'});
      }
    };
  };
}

''',

    '$name/lib/src/utils/validators.dart': '''
abstract class Validators {
  bool validate(dynamic value);
}

class EmailValidator implements Validators {
  @override
  bool validate(dynamic value) {
    return (value is! String || !value.contains('@'));
  }
}

''',

    '$name/lib/src/utils/extensions.dart': '''
extension MapExtensions on Map<String, dynamic> {
  T verifyKey<T>(String key) {
    if (!containsKey(key)) {
      throw Exception('Invalid or missing "\$key"');
    }
    if (this[key] is! T) {
      throw Exception('Invalid or missing "\$key"');
    }
    return this[key] as T;
  }
}

''',

    '$name/lib/src/utils/utils.dart': '''
export 'validators.dart';
export 'extensions.dart';
''',
  };

  for (var dir in directories) {
    print("Directory: $dir created ✅");
    Directory(dir).createSync(recursive: true);
  }

  for (var file in files.entries) {
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
