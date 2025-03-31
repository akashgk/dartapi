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
    '$name/test/controllers',
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

    '$name/lib/src/models/token_response.dart': '''
import 'package:dartapi_core/dartapi_core.dart';


class TokenResponse implements Serializable{
  final String accessToken;
  final String refreshToken;

  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  static Map<String, dynamic> get schema => {
        'type': 'object',
        'properties': {
          'accessToken': {'type': 'string'},
          'refreshToken': {'type': 'string'},
        },
      };
      
        @override
        Map<String, dynamic> toJson() {
          return {
            'accessToken': accessToken,
            'refreshToken': refreshToken
          };
        }
      
}
''',

    '$name/pubspec.yaml': '''
name: $name
description: A FastAPI-like framework for Dart.
version: 0.1.0
environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  dartapi_auth: ^0.0.2
  dartapi_core: ^0.0.1
  shelf: ^1.4.0
  shelf_cors_headers: ^0.1.5
  shelf_router: ^1.1.3

dev_dependencies:
  test: ^1.22.0
  lints: ^5.1.1
''',

    '$name/analysis_options.yaml': '''
include: package:lints/recommended.yaml

analyzer:
  exclude:
    - "**.g.dart"
    - "build/**"
    - "test/**.mocks.dart"

linter:
  rules:
    # Formatting and style
    always_declare_return_types: true
    avoid_print: true
    prefer_single_quotes: true
    omit_local_variable_types: false
    lines_longer_than_80_chars: false

    # Code quality
    prefer_const_constructors: true
    prefer_final_locals: true
    avoid_unnecessary_containers: true
    unnecessary_this: true
    depend_on_referenced_packages: true

    # Safety
    avoid_dynamic_calls: true
    avoid_catches_without_on_clauses: true
    null_closures: true
''',

    '$name/lib/src/core/server.dart': '''
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:dartapi_core/dartapi_core.dart';
import 'dart:developer';

import 'package:dartapi_auth/dartapi_auth.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'package:$name/src/core/core.dart';
import 'package:$name/src/middleware/logging.dart';

class DartAPI {
  final RouterManager _router = RouterManager();

  final jwtService = JwtService(
    accessTokenSecret: 'super-secret-key',
    refreshTokenSecret: 'super-refresh-secret',
    issuer: 'dartapi',
    audience: 'dartapi-users',
  );

  Future<void> start({int port = 8080}) async {
    final handler = const Pipeline()
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
    log('🚀 Server running on http://localhost:\$port');
  }

  void addControllers(List<BaseController> controllers) {
    for (var controller in controllers) {
      _router.registerController(controller);
    }
  }
}

''',

    '$name/test/controllers/user_controller_test.dart': '''
import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import 'package:$name/src/controllers/user_controller.dart';
import 'package:$name/src/dto/user_dto.dart';
import 'package:dartapi_auth/dartapi_auth.dart';

void main() {
  group('UserController', () {
    final jwtService = JwtService(
      accessTokenSecret: 'test-access',
      refreshTokenSecret: 'test-refresh',
      issuer: 'test',
      audience: 'test-users',
    );
    final controller = UserController(jwtService);

    test('getAllUsers should return 2 users', () async {
      final request = Request('GET', Uri.parse('http://localhost/users'));
      final response = await controller.getAllUsers(request, null);

      expect(response.length, equals(2));
      expect(response, contains('Christy'));
      expect(response, contains('Akash'));
    });

    test('createUser should return correct message', () async {
      final userDto = UserDTO(name: 'Christy', age: 25, email: 'christy@test.com');
      final request = Request(
        'POST',
        Uri.parse('http://localhost/users'),
        context: {'dto': userDto},
      );

      final response = await controller.createUser(request, userDto);
      expect(response, equals('User Christy created'));
    });
  });
}
''',
    '$name/test/controllers/auth_controller_test.dart': '''
import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import 'package:dartapi_auth/dartapi_auth.dart';
import 'package:$name/src/controllers/auth_controller.dart';
import 'package:$name/src/dto/login_dto.dart';

void main() {
  group('AuthController', () {
    final jwtService = JwtService(
      accessTokenSecret: 'test-access',
      refreshTokenSecret: 'test-refresh',
      issuer: 'test',
      audience: 'test-users',
    );
    final controller = AuthController(jwtService);

    test('should return access and refresh token on valid login', () async {
      final loginDto = LoginDTO(username: 'admin', password: '1234');
      final request = Request(
        'POST',
        Uri.parse('http://localhost/auth/login'),
        context: {'dto': loginDto},
      );

      final response = await controller.login(request, loginDto);

      expect(response.accessToken, isNotEmpty);
      expect(response.refreshToken, isNotEmpty);
    });

    test('should throw exception on invalid login', () async {
      final loginDto = LoginDTO(username: 'wrong', password: 'wrong');
      final request = Request(
        'POST',
        Uri.parse('http://localhost/auth/login'),
        context: {'dto': loginDto},
      );

      expect(() => controller.login(request, loginDto), throwsA(isA<Exception>()));
    });

    test('should return new access token on valid refresh token', () async {
      final accessToken = jwtService.generateAccessToken(claims: {'sub': 'u1'});
      final refreshToken = jwtService.generateRefreshToken(accessToken: accessToken);

      final request = Request(
        'POST',
        Uri.parse('http://localhost/auth/refresh'),
        body: 'refresh_token=\$refreshToken',
      );

      final response = await controller.refreshToken(request, null);
      expect(response['access_token'], isNotEmpty);
    });

    test('should throw error on invalid refresh token', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/auth/refresh'),
        body: 'refresh_token=invalid',
      );

      expect(() => controller.refreshToken(request, null), throwsA(isA<Exception>()));
    });
  });
}
''',

    '$name/lib/src/core/router.dart': '''
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dartapi_core/dartapi_core.dart';


class RouterManager {
  final Router _router = Router();

  Router get handler => _router;

  void registerController(BaseController controller) {
    for (ApiRoute route in controller.routes) {
      Handler finalHandler = route.handler;

      for (Middleware routeMiddleWare in route.middlewares) {
        finalHandler = routeMiddleWare(finalHandler);
      }

      _router.add(route.method.value, route.path, finalHandler);
    }
  }
}
''',
    '$name/lib/src/core/core.dart': '''
export 'router.dart';
export 'server.dart';
''',
    '$name/lib/src/controllers/auth_controller.dart': '''
import 'package:shelf/shelf.dart';
import 'package:dartapi_core/dartapi_core.dart';
import 'package:dartapi_auth/dartapi_auth.dart';

import 'package:$name/src/dto/login_dto.dart';
import 'package:$name/src/models/token_response.dart';

class AuthController extends BaseController {
  final JwtService jwtService;

  AuthController(this.jwtService);

  @override
  List<ApiRoute> get routes => [
        _loginApi(),
        _refreshTokenApi(),
      ];

  /// Login Route
  ApiRoute<LoginDTO, TokenResponse> _loginApi() {
    return ApiRoute<LoginDTO, TokenResponse>(
      method: ApiMethod.post,
      path: '/auth/login',
      typedHandler: login,
      dtoParser: (data) {
        return LoginDTO.fromJson(data);
      },
      summary: 'Login',
      description: 'Authenticate user and return access/refresh tokens.',
      requestSchema: LoginDTO.schema,
      responseSchema: TokenResponse.schema,
    );
  }

  /// Refresh Route
  ApiRoute<void, Map<String, dynamic>> _refreshTokenApi() {
    return ApiRoute<void, Map<String, dynamic>>(
      method: ApiMethod.post,
      path: '/auth/refresh',
      typedHandler: refreshToken,
      summary: 'Refresh Token',
      description: 'Use a valid refresh token to get a new access token.',
      requestSchema: {
        'type': 'object',
        'properties': {
          'refresh_token': {'type': 'string'},
        },
        'required': ['refresh_token'],
        'example': {'refresh_token': '...'}
      },
      responseSchema: {
        'type': 'object',
        'properties': {
          'access_token': {'type': 'string'},
        },
        'required': ['access_token'],
        'example': {'access_token': '...'}
      },
    );
  }

  /// Typed login handler
  Future<TokenResponse> login(Request request, LoginDTO? dto) async {
    if (dto?.username == 'admin' && dto?.password == '1234') {
      final accessToken = jwtService.generateAccessToken(claims: {
        'sub': 'user-123',
        'username': dto!.username,
      });

      final refreshToken =
          jwtService.generateRefreshToken(accessToken: accessToken);

      return TokenResponse(
          accessToken: accessToken, refreshToken: refreshToken);
    }

    throw Exception('Invalid credentials');
  }

  /// Typed refresh token handler
  Future<Map<String, dynamic>> refreshToken(Request request, void _) async {
    final body = await request.readAsString();
    final data = Uri.splitQueryString(body);

    final refreshToken = data['refresh_token'];
    if (refreshToken == null) {
      throw Exception('Missing refresh token');
    }

    final payload = jwtService.verifyRefreshToken(refreshToken);
    if (payload == null) {
      throw Exception('Invalid or expired refresh token');
    }

    final newAccessToken = jwtService.generateAccessToken(claims: {
      'sub': payload['sub'],
      'username': payload['username'],
    });

    return {'access_token': newAccessToken};
  }
}
''',
    '$name/lib/src/controllers/user_controller.dart': '''
import 'package:shelf/shelf.dart';
import 'package:dartapi_auth/dartapi_auth.dart';
import 'package:dartapi_core/dartapi_core.dart';

import 'package:$name/src/dto/user_dto.dart';

class UserController extends BaseController {
  final JwtService jwtService;

  UserController(this.jwtService);

  @override
  List<ApiRoute> get routes => [
        /// ✅ GET /users
        ApiRoute<void, List<String>>(
          method: ApiMethod.get,
          path: '/users',
          typedHandler: getAllUsers,
          middlewares: [authMiddleware(jwtService)],
          summary: 'Get all users',
          description: 'Returns a list of all usernames',
          responseSchema: {
            'type': 'array',
            'items': {'type': 'string'},
            'example': ['Christy', 'Akash'],
          },
        ),

        /// ✅ POST /users
        ApiRoute<UserDTO, String>(
          method: ApiMethod.post,
          path: '/users',
          typedHandler: createUser,
          dtoParser: (json) => UserDTO.fromJson(json),
          summary: 'Create a new user',
          description: 'Creates a new user with name and email',
          requestSchema: UserDTO.schema,
          responseSchema: {'type': 'string', 'example': 'User Christy created'},
        ),
      ];

  Future<List<String>> getAllUsers(Request request, void _) async {
    return ['Christy', 'Akash'];
  }

  Future<String> createUser(Request request, UserDTO? dto) async {
    return 'User \${dto?.name} created';
  }
}
''',

    '$name/lib/src/db/database.dart': '''
import 'dart:developer';

class Database {
  static void connect() {
    log('🔗 Connecting to database...');
  }
}
''',

    '$name/lib/src/dto/user_dto.dart': '''
import 'package:$name/src/utils/utils.dart';

class UserDTO {
  final String name;
  final int age;
  final String email;

  UserDTO({required this.name, required this.age, required this.email});

  factory UserDTO.fromJson(Map<String,dynamic> jsonData) {


    return UserDTO(
      name: jsonData.verifyKey<String>('name'),
      age: jsonData.verifyKey<int>('age'),
      email: jsonData.verifyKey<String>('email'),
    );
  }

  static const schema = {
    'type': 'object',
    'properties': {
      'name': {'type': 'string'},
      'email': {'type': 'string'}
    },
    'required': ['name', 'email'],
    'example': {'name': 'Christy', 'email': 'christy@example.com'}
  };
}



''',

    '$name/lib/src/dto/login_dto.dart': '''
import 'package:$name/src/utils/utils.dart';

class LoginDTO {
  final String username;
  final String password;

  LoginDTO({required this.username, required this.password});

  factory LoginDTO.fromJson(Map<String, dynamic> jsonData) {


    return LoginDTO(
      username: jsonData.verifyKey<String>('username'),
      password: jsonData.verifyKey<String>('password'),
    );
  }

  static Map<String, dynamic> get schema => {
        'type': 'object',
        'properties': {
          'username': {'type': 'string'},
          'password': {'type': 'string'},
        },
        'required': ['username', 'password'],
      };
}
''',

    '$name/lib/src/middleware/logging.dart': '''
import 'package:shelf/shelf.dart';
import 'dart:developer';

Middleware loggingMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      log('📌 Request: \${request.method} \${request.requestedUri}');
      final response = await innerHandler(request);
      log('📌 Response: \${request.requestedUri}, Status \${response.statusCode}');
      return response;
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
    print('Directory: $dir created ✅');
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
