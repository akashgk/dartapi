import 'package:dartapi/templates/template_engine.dart';

/// Feature flags for project scaffolding.
///
/// Pass a [Set<Feature>] to [CreateCommandConstants.directories] and
/// [CreateCommandConstants.files] to control what is generated beyond the
/// minimal base scaffold.
///
/// - [Feature.auth] — JWT authentication: [AuthController], [AuthService],
///   login DTO, token model, JWT env vars, auth service tests.
/// - [Feature.db] — Database layer: user/product CRUD (controller → service →
///   repository pattern), SQL migrations, in-memory and DB-backed repositories.
/// - [Feature.files] — File upload: [FilesController] (multipart POST +
///   GET listing, background task).
/// - [Feature.ws] — WebSocket: [WsController] echo-chat at `/ws/chat`.
enum Feature { auth, db, files, ws }

/// All four features combined — equivalent to `Feature.values.toSet()`.
const Set<Feature> kAllFeatures = {Feature.auth, Feature.db, Feature.files, Feature.ws};

class CreateCommandConstants {
  /// Returns the directory tree for a project named [name].
  ///
  /// Pass [features] to include feature-specific subdirectories.
  /// Pass `full: true` for the full kitchen-sink scaffold (implies all
  /// directories from all features).
  static List<String> directories(
    String name, {
    Set<Feature> features = const {},
    bool full = false,
  }) {
    final effective = full ? kAllFeatures : features;

    final dirs = <String>[
      '$name/lib/src/controllers',
      '$name/lib/src/config',
      '$name/lib/src/core',
      '$name/bin',
      '$name/env',
      '$name/test',
    ];

    if (effective.contains(Feature.auth) || effective.contains(Feature.db)) {
      dirs.addAll([
        '$name/lib/src/services',
        '$name/lib/src/models',
        '$name/lib/src/dto',
        '$name/test/services',
      ]);
    }

    if (effective.contains(Feature.db)) {
      dirs.addAll([
        '$name/lib/src/repositories',
        '$name/migrations',
      ]);
    }

    return dirs;
  }

  /// Returns the file map `{ destinationPath: fileContent }` for a project
  /// named [name].
  ///
  /// - No flags → minimal scaffold (hello controller + bare server).
  /// - `features: {Feature.auth}` → minimal + JWT auth wiring.
  /// - `features: {Feature.db}` → minimal + database CRUD.
  /// - `features: {Feature.auth, Feature.db, ...}` → combination.
  /// - `full: true` → full kitchen-sink scaffold (current default behaviour).
  static Future<Map<String, String>> files(
    String name, {
    Set<Feature> features = const {},
    bool full = false,
  }) async {
    return full ? _fullFiles(name) : _partialFiles(name, features);
  }

  // ── Full scaffold (--full) ─────────────────────────────────────────────────

  static Future<Map<String, String>> _fullFiles(String name) async {
    final vars = {'projectName': name};
    final entries = await Future.wait([
      // Entry point
      _load('main.dart.tmpl', vars).then((v) => MapEntry('$name/bin/main.dart', v)),
      // Config
      _load('app_config.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/config/app_config.dart', v)),
      _load('env_loader.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/config/env_loader.dart', v)),
      // Core
      _load('dartapi.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/core/dartapi.dart', v)),
      _load('core.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/core/core.dart', v)),
      // Bootstrap
      _load('bootstrap.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/core/bootstrap.dart', v)),
      // Models
      _load('token_response.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/models/token_response.dart', v)),
      _load('user.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/models/user.dart', v)),
      // DTOs
      _load('login_dto.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/dto/login_dto.dart', v)),
      _load('user_dto.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/dto/user_dto.dart', v)),
      _load('product_dto.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/dto/product_dto.dart', v)),
      // Repositories
      _load('user_repository.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/repositories/user_repository.dart', v)),
      _load('product_repository.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/repositories/product_repository.dart', v)),
      // Services
      _load('auth_service.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/services/auth_service.dart', v)),
      _load('user_service.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/services/user_service.dart', v)),
      _load('product_service.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/services/product_service.dart', v)),
      // Controllers
      _load('auth_controller.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/controllers/auth_controller.dart', v)),
      _load('user_controller.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/controllers/user_controller.dart', v)),
      _load('product_controller.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/controllers/product_controller.dart', v)),
      _load('notifications_controller.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/controllers/notifications_controller.dart', v)),
      _load('files_controller.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/controllers/files_controller.dart', v)),
      _load('ws_controller.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/controllers/ws_controller.dart', v)),
      _load('stats_controller.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/controllers/stats_controller.dart', v)),
      // Migrations
      _load('migration_users.sql.tmpl', vars).then((v) => MapEntry('$name/migrations/0001_create_users_table.sql', v)),
      _load('migration_products.sql.tmpl', vars).then((v) => MapEntry('$name/migrations/0002_create_products_table.sql', v)),
      // Tests
      _load('auth_controller_test.dart.tmpl', vars).then((v) => MapEntry('$name/test/services/auth_service_test.dart', v)),
      _load('user_controller_test.dart.tmpl', vars).then((v) => MapEntry('$name/test/services/user_service_test.dart', v)),
      // Environment files
      _load('env.example.tmpl', vars).then((v) => MapEntry('$name/env/.env.example', v)),
      _load('env.dev.tmpl', vars).then((v) => MapEntry('$name/env/.env.dev', v)),
      _load('env.staging.tmpl', vars).then((v) => MapEntry('$name/env/.env.staging', v)),
      _load('env.uat.tmpl', vars).then((v) => MapEntry('$name/env/.env.uat', v)),
      _load('env.production.tmpl', vars).then((v) => MapEntry('$name/env/.env.production', v)),
      // Project config
      _load('analysis_options.yaml.tmpl', vars).then((v) => MapEntry('$name/analysis_options.yaml', v)),
      _load('gitignore.tmpl', vars).then((v) => MapEntry('$name/.gitignore', v)),
      _load('readme.md.tmpl', vars).then((v) => MapEntry('$name/README.md', v)),
    ]);
    final map = Map<String, String>.fromEntries(entries);
    map['$name/pubspec.yaml'] = _buildPubspecContent(name, kAllFeatures);
    return map;
  }

  // ── Partial / minimal scaffold ─────────────────────────────────────────────

  static Future<Map<String, String>> _partialFiles(
    String name,
    Set<Feature> features,
  ) async {
    final vars = {'projectName': name};
    final futures = <Future<MapEntry<String, String>>>[];

    // ── Base files (always generated) ───────────────────────────────────────
    futures.addAll([
      _load('app_config.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/config/app_config.dart', v)),
      _load('env_loader.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/config/env_loader.dart', v)),
      _load('dartapi.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/core/dartapi.dart', v)),
      _load('core.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/core/core.dart', v)),
      _load('hello_controller.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/controllers/hello_controller.dart', v)),
      _load('env.example.tmpl', vars).then((v) => MapEntry('$name/env/.env.example', v)),
      _load('env.dev.tmpl', vars).then((v) => MapEntry('$name/env/.env.dev', v)),
      _load('env.staging.tmpl', vars).then((v) => MapEntry('$name/env/.env.staging', v)),
      _load('env.uat.tmpl', vars).then((v) => MapEntry('$name/env/.env.uat', v)),
      _load('env.production.tmpl', vars).then((v) => MapEntry('$name/env/.env.production', v)),
      _load('analysis_options.yaml.tmpl', vars).then((v) => MapEntry('$name/analysis_options.yaml', v)),
      _load('gitignore.tmpl', vars).then((v) => MapEntry('$name/.gitignore', v)),
      _load('readme_minimal.md.tmpl', vars).then((v) => MapEntry('$name/README.md', v)),
    ]);

    // ── auth feature ─────────────────────────────────────────────────────────
    if (features.contains(Feature.auth)) {
      futures.addAll([
        _load('auth_controller.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/controllers/auth_controller.dart', v)),
        _load('auth_service.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/services/auth_service.dart', v)),
        _load('login_dto.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/dto/login_dto.dart', v)),
        _load('token_response.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/models/token_response.dart', v)),
        _load('user.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/models/user.dart', v)),
        _load('auth_controller_test.dart.tmpl', vars).then((v) => MapEntry('$name/test/services/auth_service_test.dart', v)),
      ]);
    }

    // ── db feature ────────────────────────────────────────────────────────────
    if (features.contains(Feature.db)) {
      futures.addAll([
        _load('user_controller.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/controllers/user_controller.dart', v)),
        _load('product_controller.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/controllers/product_controller.dart', v)),
        _load('user_service.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/services/user_service.dart', v)),
        _load('product_service.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/services/product_service.dart', v)),
        _load('user_repository.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/repositories/user_repository.dart', v)),
        _load('product_repository.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/repositories/product_repository.dart', v)),
        _load('user_dto.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/dto/user_dto.dart', v)),
        _load('product_dto.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/dto/product_dto.dart', v)),
        _load('migration_users.sql.tmpl', vars).then((v) => MapEntry('$name/migrations/0001_create_users_table.sql', v)),
        _load('migration_products.sql.tmpl', vars).then((v) => MapEntry('$name/migrations/0002_create_products_table.sql', v)),
        _load('user_controller_test.dart.tmpl', vars).then((v) => MapEntry('$name/test/services/user_service_test.dart', v)),
        // user.dart model — also needed for db (skip if auth already added it)
        if (!features.contains(Feature.auth))
          _load('user.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/models/user.dart', v)),
      ]);
    }

    // ── files feature ─────────────────────────────────────────────────────────
    if (features.contains(Feature.files)) {
      futures.add(
        _load('files_controller.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/controllers/files_controller.dart', v)),
      );
    }

    // ── ws feature ────────────────────────────────────────────────────────────
    if (features.contains(Feature.ws)) {
      futures.add(
        _load('ws_controller.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/controllers/ws_controller.dart', v)),
      );
    }

    final entries = await Future.wait(futures);
    final map = Map<String, String>.fromEntries(entries);

    // Programmatically built files (content depends on features)
    map['$name/bin/main.dart'] = _buildMainContent(name, features);
    map['$name/pubspec.yaml'] = _buildPubspecContent(name, features);

    return map;
  }

  // ── Programmatic content builders ──────────────────────────────────────────

  static String _buildMainContent(String name, Set<Feature> features) {
    final buf = StringBuffer();
    final hasAuth = features.contains(Feature.auth);
    final hasDb = features.contains(Feature.db);
    final hasFiles = features.contains(Feature.files);
    final hasWs = features.contains(Feature.ws);
    final hasAny = features.isNotEmpty;

    // ── Imports ──────────────────────────────────────────────────────────────
    if (hasDb) buf.writeln("import 'dart:io';");
    if (hasAny) buf.writeln();
    buf.writeln("import 'package:dartapi_core/dartapi_core.dart';");
    if (hasDb) buf.writeln("import 'package:dartapi_db/dartapi_db.dart';");
    buf.writeln();
    buf.writeln("import 'package:$name/src/config/app_config.dart';");
    buf.writeln("import 'package:$name/src/config/env_loader.dart';");
    buf.writeln("import 'package:$name/src/controllers/hello_controller.dart';");
    if (hasAuth) {
      buf.writeln("import 'package:$name/src/controllers/auth_controller.dart';");
      buf.writeln("import 'package:$name/src/services/auth_service.dart';");
    }
    if (hasDb) {
      buf.writeln("import 'package:$name/src/controllers/product_controller.dart';");
      buf.writeln("import 'package:$name/src/controllers/user_controller.dart';");
      buf.writeln("import 'package:$name/src/repositories/product_repository.dart';");
      buf.writeln("import 'package:$name/src/repositories/user_repository.dart';");
      buf.writeln("import 'package:$name/src/services/product_service.dart';");
      buf.writeln("import 'package:$name/src/services/user_service.dart';");
    }
    if (hasFiles) {
      buf.writeln("import 'package:$name/src/controllers/files_controller.dart';");
    }
    if (hasWs) {
      buf.writeln("import 'package:$name/src/controllers/ws_controller.dart';");
    }

    // ── main() ───────────────────────────────────────────────────────────────
    buf.writeln();
    buf.writeln('Future<void> main(List<String> args) async {');

    if (hasAny) {
      buf.writeln('  final config = AppConfig(environment: _loadEnv());');
      buf.writeln('  config.validateForProduction();');
      buf.writeln('  final port = _parsePort(args, defaultPort: config.port);');
    } else {
      buf.writeln('  final port = _parsePort(args, defaultPort: 8080);');
    }
    buf.writeln();

    // Auth setup
    if (hasAuth) {
      buf.writeln('  final tokenStore = InMemoryTokenStore();');
      buf.writeln('  final jwtService = JwtService(');
      buf.writeln('    accessTokenSecret: config.jwtAccessSecret,');
      buf.writeln('    refreshTokenSecret: config.jwtRefreshSecret,');
      buf.writeln("    issuer: '$name',");
      buf.writeln("    audience: '$name-users',");
      buf.writeln('    tokenStore: tokenStore,');
      buf.writeln('  );');
      buf.writeln('  final authService = AuthService(jwtService: jwtService);');
      buf.writeln();
    }

    // DB setup
    if (hasDb) {
      buf.writeln('  DartApiDB? db;');
      buf.writeln('  if (config.dbEnabled) {');
      buf.writeln('    db = await DatabaseFactory.create(DbConfig(');
      buf.writeln('      type: DbType.postgres,');
      buf.writeln('      host: config.dbHost,');
      buf.writeln('      port: config.dbPort,');
      buf.writeln('      database: config.dbName,');
      buf.writeln('      username: config.dbUser,');
      buf.writeln('      password: config.dbPassword,');
      buf.writeln('      poolConfig: PoolConfig(maxConnections: config.dbPoolSize),');
      buf.writeln('    ));');
      buf.writeln('    await MigrationRunner(db).migrate();');
      buf.writeln('  }');
      buf.writeln('  final UserRepository userRepo =');
      buf.writeln('      db != null ? DbUserRepository(db) : InMemoryUserRepository();');
      buf.writeln('  final ProductRepository productRepo =');
      buf.writeln('      db != null ? DbProductRepository(db) : InMemoryProductRepository();');
      buf.writeln('  final userService = UserService(repository: userRepo);');
      buf.writeln('  final productService = ProductService(repository: productRepo);');
      buf.writeln();
    }

    // App construction
    if (hasAny) {
      buf.writeln("  final app = DartAPI(appName: '$name', corsOrigin: config.corsOrigin);");
    } else {
      buf.writeln("  final app = DartAPI(appName: '$name');");
    }
    buf.writeln('  app.enableHealthCheck();');
    buf.writeln();

    // Controllers
    buf.writeln('  app.addControllers([');
    buf.writeln('    HelloController(),');
    if (hasAuth) {
      buf.writeln('    AuthController(authService: authService, jwtService: jwtService),');
    }
    if (hasDb) {
      final jwtArg = hasAuth ? ', jwtService: jwtService' : '';
      buf.writeln('    UserController(userService: userService$jwtArg),');
      buf.writeln('    ProductController(productService: productService$jwtArg),');
    }
    if (hasFiles) {
      final jwtArg = hasAuth ? 'jwtService: jwtService' : '';
      buf.writeln('    FilesController($jwtArg),');
    }
    if (hasWs) {
      final jwtArg = hasAuth ? 'jwtService: jwtService' : '';
      buf.writeln('    WsController($jwtArg),');
    }
    buf.writeln('  ]);');
    buf.writeln();

    // Shutdown hook
    if (hasDb) {
      buf.writeln('  app.onShutdown(() async => db?.close());');
      buf.writeln();
    }

    buf.writeln('  await app.start(port: port);');
    buf.writeln('}');

    // ── Helpers ───────────────────────────────────────────────────────────────
    buf.writeln();
    buf.writeln('int _parsePort(List<String> args, {required int defaultPort}) {');
    buf.writeln('  for (var i = 0; i < args.length; i++) {');
    buf.writeln("    if (args[i] == '--port' && i + 1 < args.length) {");
    buf.writeln('      return int.tryParse(args[i + 1]) ?? defaultPort;');
    buf.writeln('    }');
    buf.writeln("    if (args[i].startsWith('--port=')) {");
    buf.writeln("      return int.tryParse(args[i].split('=')[1]) ?? defaultPort;");
    buf.writeln('    }');
    buf.writeln('  }');
    buf.writeln('  return defaultPort;');
    buf.writeln('}');

    if (hasAny) {
      buf.writeln();
      buf.writeln('Map<String, String> _loadEnv() {');
      buf.writeln("  final appEnv = Platform.environment['APP_ENV'] ?? 'dev';");
      buf.writeln('  return mergeEnv([');
      buf.writeln("    loadEnvFile('env/.env'),");
      buf.writeln("    loadEnvFile('env/.env.\$appEnv'),");
      buf.writeln('  ]);');
      buf.writeln('}');
    }

    return buf.toString();
  }

  static String _buildPubspecContent(String name, Set<Feature> features) {
    final buf = StringBuffer();
    buf.writeln('name: $name');
    buf.writeln('description: $name is built with DartAPI');
    buf.writeln("publish_to: 'none'");
    buf.writeln('version: 0.1.0');
    buf.writeln('environment:');
    buf.writeln('  sdk: ^3.7.0');
    buf.writeln();
    buf.writeln('dependencies:');
    buf.writeln('  dartapi_core: ^0.1.1');
    if (features.contains(Feature.db)) {
      buf.writeln('  dartapi_db: ^0.0.12');
    }
    if (features.contains(Feature.ws)) {
      buf.writeln('  shelf_web_socket: ^3.0.0');
      buf.writeln('  web_socket_channel: ^3.0.3');
    }
    buf.writeln();
    buf.writeln('dev_dependencies:');
    buf.writeln('  test: ^1.24.0');
    buf.writeln('  lints: ^6.1.0');
    return buf.toString();
  }

  static Future<String> _load(String name, Map<String, String> vars) =>
      TemplateEngine.render(name, vars);
}
