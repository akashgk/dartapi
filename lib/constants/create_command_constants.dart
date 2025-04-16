class CreateCommandConstants {
  // Directories list generator
  static List<String> directories(String name) => [
    '$name/lib/src/core',
    '$name/lib/src/controllers',
    '$name/lib/src/models',
    '$name/lib/src/dto',
    '$name/bin',
    '$name/test',
    '$name/test/controllers',
  ];

  // Files map generator
  static Map<String, String> files(String name) => {
    '$name/bin/main.dart': _mainDart(name),
    '$name/lib/src/models/token_response.dart': _tokenResponseDart,
    '$name/pubspec.yaml': _pubspecYaml(name),
    '$name/analysis_options.yaml': _analysisOptions,
    '$name/lib/src/core/dartapi.dart': _dartApi(name),
    '$name/test/controllers/user_controller_test.dart': _userControllerTest(
      name,
    ),
    '$name/test/controllers/auth_controller_test.dart': _authControllerTest(
      name,
    ),
    '$name/lib/src/core/router.dart': _routerDart,
    '$name/lib/src/core/core.dart': _coreExport,
    '$name/lib/src/controllers/auth_controller.dart': _authControllerDart(name),
    '$name/lib/src/controllers/user_controller.dart': _userControllerDart(name),
    '$name/lib/src/controllers/product_controller.dart': _productControllerDart(
      name
    ),
    '$name/lib/src/dto/user_dto.dart': _userDtoDart(name),
    '$name/lib/src/dto/login_dto.dart': _loginDtoDart,
    '$name/lib/src/dto/product_dto.dart': _productDtoDart,
  };

  // Static file contents
  static String _mainDart(String projectName) => '''
import 'package:$projectName/src/controllers/product_controller.dart';
import 'package:$projectName/src/core/core.dart';
import 'package:$projectName/src/controllers/user_controller.dart';
import 'package:$projectName/src/controllers/auth_controller.dart';
import 'package:dartapi_auth/dartapi_auth.dart';
import 'package:dartapi_db/dartapi_db.dart';

void main(List<String> args) async {
  int port = 8080; // Default port

  // Parse command-line arguments for port
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--port' && i + 1 < args.length) {
      port = int.tryParse(args[i + 1]) ?? 8080;
      break;
    }
  }

  final config = const DbConfig(
    type: DbType.postgres,
    host: 'localhost',
    port: 5432,
    database: 'dartapi_test',
    username: 'postgres',
    password: 'yourpassword',
  );

  final DartApiDB db = await DatabaseFactory.create(config);
  final jwtService = JwtService(
    accessTokenSecret: 'super-secret-key',
    refreshTokenSecret: 'super-refresh-secret',
    issuer: 'dartapi',
    audience: 'dartapi-users',
  );

  final app = DartAPI(db: db, jwtService: jwtService);

  app.addControllers([
    UserController(app.jwtService!),
    AuthController(app.jwtService!),
    ProductController(db, app.jwtService!)
  ]);

  app.start(port: port);
}
''';
  static const String _tokenResponseDart = '''
import 'package:dartapi_core/dartapi_core.dart';

class TokenResponse implements Serializable {
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
    return {'accessToken': accessToken, 'refreshToken': refreshToken};
  }
}

''';
  static String _pubspecYaml(String projectName) => '''
name: $projectName
description: $projectName is built with DartAPI
publish_to: 'none' # Remove this line if you wish to publish to pub.dev
version: 0.1.0
environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  dartapi_auth: ^0.0.3
  dartapi_core: ^0.0.3
  dartapi_db: ^0.0.2
  shelf: ^1.4.0
  shelf_cors_headers: ^0.1.5
  shelf_router: ^1.1.3

dev_dependencies:
  test: ^1.22.0
  lints: ^5.1.1

''';
  static const String _analysisOptions = '''
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

''';
  static String _dartApi(String projectName) => '''
import 'package:dartapi_auth/dartapi_auth.dart';
import 'package:dartapi_db/dartapi_db.dart';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:dartapi_core/dartapi_core.dart';
import 'dart:developer';


import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'package:$projectName/src/core/core.dart';

class DartAPI {
  final RouterManager _router = RouterManager();

  final DartApiDB? db;
  final JwtService? jwtService;

  DartAPI({this.db, this.jwtService});

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


''';
  static String _userControllerTest(String projectName) => '''
import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import 'package:$projectName/src/controllers/user_controller.dart';
import 'package:$projectName/src/dto/user_dto.dart';
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
      final userDto =
          UserDTO(name: 'Christy', age: 25, email: 'christy@test.com');
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

''';
  static String _authControllerTest(String projectName) => '''
import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import 'package:dartapi_auth/dartapi_auth.dart';
import 'package:$projectName/src/controllers/auth_controller.dart';
import 'package:$projectName/src/dto/login_dto.dart';

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

      expect(
          () => controller.login(request, loginDto), throwsA(isA<Exception>()));
    });

    test('should return new access token on valid refresh token', () async {
      final accessToken = jwtService.generateAccessToken(claims: {'sub': 'u1'});
      final refreshToken =
          jwtService.generateRefreshToken(accessToken: accessToken);

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

      expect(() => controller.refreshToken(request, null),
          throwsA(isA<Exception>()));
    });
  });
}

''';
  static const String _routerDart = '''
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

''';
  static const String _coreExport = '''
export 'router.dart';
export 'dartapi.dart';
''';
  static String _authControllerDart(String projectName) => '''
import 'package:shelf/shelf.dart';
import 'package:dartapi_core/dartapi_core.dart';
import 'package:dartapi_auth/dartapi_auth.dart';

import 'package:$projectName/src/dto/login_dto.dart';
import 'package:$projectName/src/models/token_response.dart';

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
    if (dto?.username == 'admin@mail.com' && dto?.password == '1234') {
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
''';
  static String _productControllerDart(String projectName) => '''
import 'package:$projectName/src/dto/product_dto.dart';
import 'package:dartapi_auth/dartapi_auth.dart';
import 'package:shelf/shelf.dart';
import 'package:dartapi_core/dartapi_core.dart';
import 'package:dartapi_db/dartapi_db.dart';

class ProductController extends BaseController {
  final DartApiDB db;
  final JwtService jwtService;

  ProductController(this.db, this.jwtService);

  @override
  List<ApiRoute> get routes => [
        ApiRoute<void, List<ProductDto>>(
          method: ApiMethod.get,
          path: '/products',
          typedHandler: getAll,
          summary: 'Get all products',
          description: 'Returns all products in the system',
          middlewares: [
            authMiddleware(jwtService),
          ],
          responseSchema: {
            'type': 'array',
            'items': ProductDto.schema,
          },
        ),
        ApiRoute<ProductDto, ProductDto>(
          method: ApiMethod.post,
          path: '/products',
          typedHandler: create,
          middlewares: [
            authMiddleware(jwtService),
          ],
          dtoParser: (data) {
            return ProductDto.fromJson(data);
          },
          summary: 'Create a new product',
          description: 'Adds a new product to the database',
          requestSchema: ProductDto.schema,
          responseSchema: ProductDto.schema,
        ),
      ];

  Future<List<ProductDto>> getAll(Request req, void _) async {
    final DbResult result = await db.select('products');
    return result.rows.map(ProductDto.fromRow).toList();
  }

  Future<ProductDto> create(Request req, ProductDto? dto) async {
    if (dto == null) {
      throw Response.badRequest(
        body: 'Invalid product data',
      );
    }
    final result = await db.insert('products', dto.toJson());
    if (result.rows.isEmpty) {
      throw Response.internalServerError(
        body: 'Failed to create product',
      );
    }
    return ProductDto.fromRow(result.rows.first);
  }
}
''';
  static String _userControllerDart(String projectName) => '''
import 'package:shelf/shelf.dart';
import 'package:dartapi_auth/dartapi_auth.dart';
import 'package:dartapi_core/dartapi_core.dart';

import 'package:$projectName/src/dto/user_dto.dart';

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
''';
  static String _userDtoDart(String projectName) => '''
import 'package:dartapi_core/dartapi_core.dart';

class UserDTO {
  final String name;
  final int age;
  final String email;

  UserDTO({required this.name, required this.age, required this.email});

  factory UserDTO.fromJson(Map<String, dynamic> jsonData) {
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
''';

  static const String _productDtoDart = '''
import 'package:dartapi_core/dartapi_core.dart';

class ProductDto  implements Serializable {
  final int? id;
  final String name;
  final double price;
  final int quantity;

  ProductDto({
    this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      name: json.verifyKey<String>('name'),
      price: json.verifyKey<num>('price').toDouble(),
      quantity: json.verifyKey<int>('quantity'),
    );
  }

  factory ProductDto.fromRow(Map<String, dynamic> row) {
    return ProductDto(
      id: row.verifyKey<int>('id'),
      name: row.verifyKey<String>('name'),
      price: row.verifyKey<num>('price').toDouble(),
      quantity: row.verifyKey<int>('quantity'),
    );
  }
  @override
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
      };

  static const schema = {
    'type': 'object',
    'properties': {
      'id': {'type': 'integer'},
      'name': {'type': 'string'},
      'price': {'type': 'number'},
      'quantity': {'type': 'integer'},
    },
    'required': ['name', 'price', 'quantity'],
    'example': {
      'id': 1,
      'name': 'Keyboard',
      'price': 29.99,
      'quantity': 15,
    }
  };
}
''';
  static const String _loginDtoDart = '''
import 'package:dartapi_core/dartapi_core.dart';

class LoginDTO {
  final String username;
  final String password;

  LoginDTO({required this.username, required this.password});

  factory LoginDTO.fromJson(Map<String, dynamic> jsonData) {
    return LoginDTO(
      username: jsonData.verifyKey<String>('username', validators: [
        EmailValidator('Invalid email format'),
      ]),
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
''';
}
