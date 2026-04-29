import 'package:dartapi/constants/create_command_constants.dart';
import 'package:test/test.dart';

void main() {
  // ── Feature enum ─────────────────────────────────────────────────────────

  group('Feature enum', () {
    test('has four values: auth, db, files, ws', () {
      expect(Feature.values, hasLength(4));
      expect(
        Feature.values,
        containsAll([Feature.auth, Feature.db, Feature.files, Feature.ws]),
      );
    });

    test('kAllFeatures contains all four features', () {
      expect(kAllFeatures, containsAll(Feature.values));
      expect(kAllFeatures, hasLength(4));
    });
  });

  // ── directories() — minimal ───────────────────────────────────────────────

  group('directories() — minimal (no features)', () {
    late List<String> dirs;
    setUp(() => dirs = CreateCommandConstants.directories('myapp'));

    test('returns base directories', () {
      expect(
        dirs,
        containsAll([
          'myapp/lib/src/controllers',
          'myapp/lib/src/config',
          'myapp/lib/src/core',
          'myapp/bin',
          'myapp/env',
          'myapp/test',
        ]),
      );
    });

    test('does not include services, models, dto, repositories, or migrations', () {
      expect(dirs, isNot(contains('myapp/lib/src/services')));
      expect(dirs, isNot(contains('myapp/lib/src/models')));
      expect(dirs, isNot(contains('myapp/lib/src/dto')));
      expect(dirs, isNot(contains('myapp/lib/src/repositories')));
      expect(dirs, isNot(contains('myapp/migrations')));
    });

    test('all paths are prefixed with the project name', () {
      for (final d in dirs) {
        expect(d, startsWith('myapp/'));
      }
    });
  });

  group('directories() — with auth', () {
    late List<String> dirs;
    setUp(
      () => dirs = CreateCommandConstants.directories('myapp', features: {Feature.auth}),
    );

    test('includes services, models, dto, and test/services', () {
      expect(
        dirs,
        containsAll([
          'myapp/lib/src/services',
          'myapp/lib/src/models',
          'myapp/lib/src/dto',
          'myapp/test/services',
        ]),
      );
    });

    test('does not include repositories or migrations', () {
      expect(dirs, isNot(contains('myapp/lib/src/repositories')));
      expect(dirs, isNot(contains('myapp/migrations')));
    });
  });

  group('directories() — with db', () {
    late List<String> dirs;
    setUp(
      () => dirs = CreateCommandConstants.directories('myapp', features: {Feature.db}),
    );

    test('includes repositories and migrations in addition to services/models/dto', () {
      expect(
        dirs,
        containsAll([
          'myapp/lib/src/services',
          'myapp/lib/src/models',
          'myapp/lib/src/dto',
          'myapp/lib/src/repositories',
          'myapp/migrations',
          'myapp/test/services',
        ]),
      );
    });
  });

  group('directories() — full', () {
    late List<String> dirs;
    setUp(() => dirs = CreateCommandConstants.directories('myapp', full: true));

    test('includes all directories', () {
      expect(
        dirs,
        containsAll([
          'myapp/lib/src/controllers',
          'myapp/lib/src/config',
          'myapp/lib/src/core',
          'myapp/lib/src/services',
          'myapp/lib/src/models',
          'myapp/lib/src/dto',
          'myapp/lib/src/repositories',
          'myapp/migrations',
          'myapp/bin',
          'myapp/env',
          'myapp/test',
          'myapp/test/services',
        ]),
      );
    });
  });

  // ── files() — minimal ─────────────────────────────────────────────────────

  group('files() — minimal (no features)', () {
    late Map<String, String> fileMap;
    setUpAll(() async {
      fileMap = await CreateCommandConstants.files('myapp');
    });

    test('generates the minimal file set', () {
      expect(
        fileMap.keys,
        containsAll([
          'myapp/bin/main.dart',
          'myapp/pubspec.yaml',
          'myapp/analysis_options.yaml',
          'myapp/.gitignore',
          'myapp/README.md',
          'myapp/lib/src/core/dartapi.dart',
          'myapp/lib/src/core/core.dart',
          'myapp/lib/src/config/app_config.dart',
          'myapp/lib/src/config/env_loader.dart',
          'myapp/lib/src/controllers/hello_controller.dart',
          'myapp/env/.env.example',
          'myapp/env/.env.dev',
          'myapp/env/.env.staging',
          'myapp/env/.env.uat',
          'myapp/env/.env.production',
        ]),
      );
    });

    test('does NOT generate auth, db, files, or ws controllers', () {
      expect(
        fileMap.keys,
        isNot(contains('myapp/lib/src/controllers/auth_controller.dart')),
      );
      expect(
        fileMap.keys,
        isNot(contains('myapp/lib/src/controllers/user_controller.dart')),
      );
      expect(
        fileMap.keys,
        isNot(contains('myapp/lib/src/controllers/product_controller.dart')),
      );
      expect(
        fileMap.keys,
        isNot(contains('myapp/lib/src/controllers/files_controller.dart')),
      );
      expect(
        fileMap.keys,
        isNot(contains('myapp/lib/src/controllers/ws_controller.dart')),
      );
    });

    test('does NOT generate bootstrap.dart', () {
      expect(fileMap.keys, isNot(contains('myapp/lib/src/core/bootstrap.dart')));
    });

    test('does NOT generate migrations', () {
      expect(
        fileMap.keys,
        isNot(contains('myapp/migrations/0001_create_users_table.sql')),
      );
    });

    test('hello_controller.dart defines HelloController', () {
      expect(
        fileMap['myapp/lib/src/controllers/hello_controller.dart'],
        contains('class HelloController'),
      );
    });

    test('hello_controller.dart has GET /hello route', () {
      expect(
        fileMap['myapp/lib/src/controllers/hello_controller.dart'],
        contains('/hello'),
      );
    });

    test('hello_controller.dart has no unsubstituted placeholders', () {
      expect(
        fileMap['myapp/lib/src/controllers/hello_controller.dart'],
        isNot(contains('{{projectName}}')),
      );
    });

    test('pubspec.yaml includes only dartapi_core', () {
      final pubspec = fileMap['myapp/pubspec.yaml']!;
      expect(pubspec, contains('dartapi_core'));
      expect(pubspec, isNot(contains('dartapi_db')));
      expect(pubspec, isNot(contains('shelf_web_socket')));
      expect(pubspec, isNot(contains('dartapi_auth')));
    });

    test('pubspec.yaml contains the project name', () {
      expect(fileMap['myapp/pubspec.yaml'], contains('name: myapp'));
    });

    test('main.dart imports hello_controller', () {
      expect(fileMap['myapp/bin/main.dart'], contains('hello_controller.dart'));
    });

    test('main.dart does NOT import JwtService or database in minimal mode', () {
      final main = fileMap['myapp/bin/main.dart']!;
      expect(main, isNot(contains('JwtService')));
      expect(main, isNot(contains('dartapi_db')));
    });

    test('main.dart calls app.start()', () {
      expect(fileMap['myapp/bin/main.dart'], contains('app.start('));
    });

    test('main.dart adds HelloController', () {
      expect(fileMap['myapp/bin/main.dart'], contains('HelloController()'));
    });

    test('README.md is generated (minimal version)', () {
      final readme = fileMap['myapp/README.md']!;
      expect(readme, contains('myapp'));
      expect(readme, contains('/hello'));
    });

    test('README.md has no unsubstituted placeholders', () {
      expect(fileMap['myapp/README.md'], isNot(contains('{{projectName}}')));
    });

    test('.gitignore excludes env/.env files', () {
      expect(fileMap['myapp/.gitignore'], contains('env/.env'));
    });

    test('env/.env.dev sets APP_ENV=dev', () {
      expect(fileMap['myapp/env/.env.dev'], contains('APP_ENV=dev'));
    });

    test('no file has unsubstituted {{projectName}} placeholder', () {
      for (final entry in fileMap.entries) {
        expect(
          entry.value,
          isNot(contains('{{projectName}}')),
          reason: '${entry.key} still has {{projectName}}',
        );
      }
    });
  });

  // ── files() — with=auth ───────────────────────────────────────────────────

  group('files() — with=auth', () {
    late Map<String, String> fileMap;
    setUpAll(() async {
      fileMap = await CreateCommandConstants.files('myapp', features: {Feature.auth});
    });

    test('generates hello_controller AND auth_controller', () {
      expect(
        fileMap.keys,
        containsAll([
          'myapp/lib/src/controllers/hello_controller.dart',
          'myapp/lib/src/controllers/auth_controller.dart',
          'myapp/lib/src/services/auth_service.dart',
          'myapp/lib/src/dto/login_dto.dart',
          'myapp/lib/src/models/token_response.dart',
          'myapp/lib/src/models/user.dart',
          'myapp/test/services/auth_service_test.dart',
        ]),
      );
    });

    test('does NOT generate db controllers or migrations', () {
      expect(
        fileMap.keys,
        isNot(contains('myapp/lib/src/controllers/user_controller.dart')),
      );
      expect(
        fileMap.keys,
        isNot(contains('myapp/lib/src/controllers/product_controller.dart')),
      );
      expect(
        fileMap.keys,
        isNot(contains('myapp/migrations/0001_create_users_table.sql')),
      );
    });

    test('main.dart imports JwtService (via dartapi_core)', () {
      expect(fileMap['myapp/bin/main.dart'], contains('dartapi_core'));
    });

    test('main.dart wires AuthController', () {
      expect(fileMap['myapp/bin/main.dart'], contains('AuthController'));
    });

    test('main.dart creates JwtService', () {
      expect(fileMap['myapp/bin/main.dart'], contains('JwtService'));
    });

    test('main.dart calls config.validateForProduction()', () {
      expect(fileMap['myapp/bin/main.dart'], contains('validateForProduction'));
    });

    test('pubspec.yaml does NOT add dartapi_db', () {
      expect(fileMap['myapp/pubspec.yaml'], isNot(contains('dartapi_db')));
    });

    test('no file has unsubstituted {{projectName}} placeholder', () {
      for (final entry in fileMap.entries) {
        expect(
          entry.value,
          isNot(contains('{{projectName}}')),
          reason: '${entry.key} still has {{projectName}}',
        );
      }
    });
  });

  // ── files() — with=db ────────────────────────────────────────────────────

  group('files() — with=db', () {
    late Map<String, String> fileMap;
    setUpAll(() async {
      fileMap = await CreateCommandConstants.files('myapp', features: {Feature.db});
    });

    test('generates user/product CRUD and migrations', () {
      expect(
        fileMap.keys,
        containsAll([
          'myapp/lib/src/controllers/user_controller.dart',
          'myapp/lib/src/controllers/product_controller.dart',
          'myapp/lib/src/services/user_service.dart',
          'myapp/lib/src/services/product_service.dart',
          'myapp/lib/src/repositories/user_repository.dart',
          'myapp/lib/src/repositories/product_repository.dart',
          'myapp/lib/src/dto/user_dto.dart',
          'myapp/lib/src/dto/product_dto.dart',
          'myapp/lib/src/models/user.dart',
          'myapp/migrations/0001_create_users_table.sql',
          'myapp/migrations/0002_create_products_table.sql',
          'myapp/test/services/user_service_test.dart',
        ]),
      );
    });

    test('does NOT generate auth_controller', () {
      expect(
        fileMap.keys,
        isNot(contains('myapp/lib/src/controllers/auth_controller.dart')),
      );
    });

    test('pubspec.yaml includes dartapi_db', () {
      expect(fileMap['myapp/pubspec.yaml'], contains('dartapi_db'));
    });

    test('pubspec.yaml does NOT include shelf_web_socket', () {
      expect(fileMap['myapp/pubspec.yaml'], isNot(contains('shelf_web_socket')));
    });

    test('main.dart imports dartapi_db', () {
      expect(fileMap['myapp/bin/main.dart'], contains('dartapi_db'));
    });

    test('main.dart wires UserController and ProductController', () {
      final main = fileMap['myapp/bin/main.dart']!;
      expect(main, contains('UserController'));
      expect(main, contains('ProductController'));
    });

    test('main.dart creates DB connection and runs migrations', () {
      final main = fileMap['myapp/bin/main.dart']!;
      expect(main, contains('DatabaseFactory.create'));
      expect(main, contains('MigrationRunner'));
    });

    test('user_controller.dart has optional jwtService', () {
      expect(
        fileMap['myapp/lib/src/controllers/user_controller.dart'],
        contains('JwtService?'),
      );
    });

    test('product_controller.dart has optional jwtService', () {
      expect(
        fileMap['myapp/lib/src/controllers/product_controller.dart'],
        contains('JwtService?'),
      );
    });

    test('no file has unsubstituted {{projectName}} placeholder', () {
      for (final entry in fileMap.entries) {
        expect(
          entry.value,
          isNot(contains('{{projectName}}')),
          reason: '${entry.key} still has {{projectName}}',
        );
      }
    });
  });

  // ── files() — with=auth,db ────────────────────────────────────────────────

  group('files() — with=auth,db', () {
    late Map<String, String> fileMap;
    setUpAll(() async {
      fileMap = await CreateCommandConstants.files(
        'myapp',
        features: {Feature.auth, Feature.db},
      );
    });

    test('generates auth AND db files without duplication of user.dart', () {
      expect(
        fileMap.keys,
        containsAll([
          'myapp/lib/src/controllers/auth_controller.dart',
          'myapp/lib/src/controllers/user_controller.dart',
          'myapp/lib/src/controllers/product_controller.dart',
          'myapp/lib/src/services/auth_service.dart',
          'myapp/lib/src/models/user.dart',
          'myapp/lib/src/models/token_response.dart',
          'myapp/migrations/0001_create_users_table.sql',
        ]),
      );
    });

    test('user.dart is generated exactly once (not duplicated)', () {
      final matches = fileMap.keys.where((k) => k.endsWith('user.dart')).toList();
      expect(matches, hasLength(1));
    });

    test('main.dart wires JwtService into UserController', () {
      final main = fileMap['myapp/bin/main.dart']!;
      expect(
        main,
        contains('UserController(userService: userService, jwtService: jwtService)'),
      );
    });

    test('main.dart wires JwtService into ProductController', () {
      final main = fileMap['myapp/bin/main.dart']!;
      expect(
        main,
        contains(
          'ProductController(productService: productService, jwtService: jwtService)',
        ),
      );
    });

    test('pubspec.yaml includes both dartapi_core and dartapi_db', () {
      final pubspec = fileMap['myapp/pubspec.yaml']!;
      expect(pubspec, contains('dartapi_core'));
      expect(pubspec, contains('dartapi_db'));
    });

    test('no file has unsubstituted {{projectName}} placeholder', () {
      for (final entry in fileMap.entries) {
        expect(
          entry.value,
          isNot(contains('{{projectName}}')),
          reason: '${entry.key} still has {{projectName}}',
        );
      }
    });
  });

  // ── files() — with=files ──────────────────────────────────────────────────

  group('files() — with=files', () {
    late Map<String, String> fileMap;
    setUpAll(() async {
      fileMap = await CreateCommandConstants.files('myapp', features: {Feature.files});
    });

    test('generates files_controller', () {
      expect(fileMap.keys, contains('myapp/lib/src/controllers/files_controller.dart'));
    });

    test('files_controller.dart has optional jwtService', () {
      expect(
        fileMap['myapp/lib/src/controllers/files_controller.dart'],
        contains('JwtService?'),
      );
    });

    test('main.dart wires FilesController', () {
      expect(fileMap['myapp/bin/main.dart'], contains('FilesController()'));
    });

    test('pubspec.yaml has only dartapi_core (no ws deps)', () {
      final pubspec = fileMap['myapp/pubspec.yaml']!;
      expect(pubspec, contains('dartapi_core'));
      expect(pubspec, isNot(contains('shelf_web_socket')));
    });
  });

  // ── files() — with=ws ─────────────────────────────────────────────────────

  group('files() — with=ws', () {
    late Map<String, String> fileMap;
    setUpAll(() async {
      fileMap = await CreateCommandConstants.files('myapp', features: {Feature.ws});
    });

    test('generates ws_controller', () {
      expect(fileMap.keys, contains('myapp/lib/src/controllers/ws_controller.dart'));
    });

    test('ws_controller.dart has optional jwtService', () {
      expect(
        fileMap['myapp/lib/src/controllers/ws_controller.dart'],
        contains('JwtService?'),
      );
    });

    test('main.dart wires WsController', () {
      expect(fileMap['myapp/bin/main.dart'], contains('WsController()'));
    });

    test('pubspec.yaml includes shelf_web_socket and web_socket_channel', () {
      final pubspec = fileMap['myapp/pubspec.yaml']!;
      expect(pubspec, contains('shelf_web_socket'));
      expect(pubspec, contains('web_socket_channel'));
    });
  });

  // ── files() — with=auth,ws ────────────────────────────────────────────────

  group('files() — with=auth,ws', () {
    late Map<String, String> fileMap;
    setUpAll(() async {
      fileMap = await CreateCommandConstants.files(
        'myapp',
        features: {Feature.auth, Feature.ws},
      );
    });

    test('wires jwtService into WsController', () {
      expect(
        fileMap['myapp/bin/main.dart'],
        contains('WsController(jwtService: jwtService)'),
      );
    });

    test('pubspec includes both dartapi_core and ws deps', () {
      final pubspec = fileMap['myapp/pubspec.yaml']!;
      expect(pubspec, contains('dartapi_core'));
      expect(pubspec, contains('shelf_web_socket'));
    });
  });

  // ── files() — full ────────────────────────────────────────────────────────

  group('files() — full', () {
    late Map<String, String> fileMap;
    setUpAll(() async {
      fileMap = await CreateCommandConstants.files('myapp', full: true);
    });

    test('generates all file groups', () {
      expect(
        fileMap.keys,
        containsAll([
          'myapp/bin/main.dart',
          'myapp/pubspec.yaml',
          'myapp/analysis_options.yaml',
          'myapp/.gitignore',
          'myapp/README.md',
          'myapp/lib/src/core/dartapi.dart',
          'myapp/lib/src/core/core.dart',
          'myapp/lib/src/core/bootstrap.dart',
          'myapp/lib/src/config/app_config.dart',
          'myapp/lib/src/config/env_loader.dart',
          'myapp/lib/src/controllers/auth_controller.dart',
          'myapp/lib/src/controllers/user_controller.dart',
          'myapp/lib/src/controllers/product_controller.dart',
          'myapp/lib/src/controllers/notifications_controller.dart',
          'myapp/lib/src/controllers/files_controller.dart',
          'myapp/lib/src/controllers/ws_controller.dart',
          'myapp/lib/src/controllers/stats_controller.dart',
          'myapp/lib/src/services/auth_service.dart',
          'myapp/lib/src/services/user_service.dart',
          'myapp/lib/src/services/product_service.dart',
          'myapp/lib/src/repositories/user_repository.dart',
          'myapp/lib/src/repositories/product_repository.dart',
          'myapp/lib/src/dto/login_dto.dart',
          'myapp/lib/src/dto/user_dto.dart',
          'myapp/lib/src/dto/product_dto.dart',
          'myapp/lib/src/models/token_response.dart',
          'myapp/lib/src/models/user.dart',
          'myapp/migrations/0001_create_users_table.sql',
          'myapp/migrations/0002_create_products_table.sql',
          'myapp/test/services/auth_service_test.dart',
          'myapp/test/services/user_service_test.dart',
          'myapp/env/.env.example',
          'myapp/env/.env.dev',
          'myapp/env/.env.staging',
          'myapp/env/.env.uat',
          'myapp/env/.env.production',
        ]),
      );
    });

    test('bootstrap.dart defines createApp function', () {
      expect(
        fileMap['myapp/lib/src/core/bootstrap.dart'],
        contains('DartAPI createApp('),
      );
    });

    test('bootstrap.dart passes corsOrigin to DartAPI', () {
      expect(
        fileMap['myapp/lib/src/core/bootstrap.dart'],
        contains('corsOrigin: config.corsOrigin'),
      );
    });

    test('main.dart imports bootstrap', () {
      expect(fileMap['myapp/bin/main.dart'], contains('bootstrap.dart'));
    });

    test('main.dart calls createApp()', () {
      expect(fileMap['myapp/bin/main.dart'], contains('createApp('));
    });

    test('main.dart calls validateForProduction()', () {
      expect(fileMap['myapp/bin/main.dart'], contains('validateForProduction'));
    });

    test('main.dart loads environment-specific env file from env/ folder', () {
      expect(fileMap['myapp/bin/main.dart'], contains('env/.env.\$appEnv'));
    });

    test('pubspec.yaml includes dartapi_core, dartapi_db, and ws deps', () {
      final pubspec = fileMap['myapp/pubspec.yaml']!;
      expect(pubspec, contains('dartapi_core'));
      expect(pubspec, contains('dartapi_db'));
      expect(pubspec, contains('shelf_web_socket'));
      expect(pubspec, contains('web_socket_channel'));
    });

    test('pubspec.yaml does NOT include dartapi_auth', () {
      expect(fileMap['myapp/pubspec.yaml'], isNot(contains('dartapi_auth')));
    });

    test('pubspec.yaml does NOT include dotenv', () {
      expect(fileMap['myapp/pubspec.yaml'], isNot(contains('dotenv')));
    });

    test('app_config.dart extends core.AppConfig', () {
      expect(
        fileMap['myapp/lib/src/config/app_config.dart'],
        contains('extends core.AppConfig'),
      );
    });

    test('app_config.dart imports dartapi_core as core', () {
      expect(fileMap['myapp/lib/src/config/app_config.dart'], contains('as core'));
    });

    test('app_config.dart overrides dbName with the project name', () {
      expect(fileMap['myapp/lib/src/config/app_config.dart'], contains('dbName'));
    });

    test('env_loader.dart exports loadEnvFile and mergeEnv', () {
      final loader = fileMap['myapp/lib/src/config/env_loader.dart']!;
      expect(loader, contains('loadEnvFile'));
      expect(loader, contains('mergeEnv'));
    });

    test('env/.env.example contains APP_ENV', () {
      expect(fileMap['myapp/env/.env.example'], contains('APP_ENV'));
    });

    test('env/.env.dev sets APP_ENV=dev', () {
      expect(fileMap['myapp/env/.env.dev'], contains('APP_ENV=dev'));
    });

    test('env/.env.production sets DEBUG=false', () {
      expect(fileMap['myapp/env/.env.production'], contains('DEBUG=false'));
    });

    test('.gitignore excludes env/.env files but not env/.env.example', () {
      final gitignore = fileMap['myapp/.gitignore']!;
      expect(gitignore, contains('env/.env'));
      final ignoreLines =
          gitignore.split('\n').where((l) => !l.trimLeft().startsWith('#')).toList();
      expect(ignoreLines, isNot(contains('env/.env.example')));
    });

    test('auth_controller.dart defines AuthController', () {
      expect(
        fileMap['myapp/lib/src/controllers/auth_controller.dart'],
        contains('class AuthController'),
      );
    });

    test('user_controller.dart defines UserController with optional jwtService', () {
      final uc = fileMap['myapp/lib/src/controllers/user_controller.dart']!;
      expect(uc, contains('class UserController'));
      expect(uc, contains('JwtService?'));
    });

    test('dartapi.dart re-exports DartAPI from dartapi_core', () {
      expect(fileMap['myapp/lib/src/core/dartapi.dart'], contains('dartapi_core'));
    });

    test('README.md mentions all environments', () {
      final readme = fileMap['myapp/README.md']!;
      expect(readme, contains('APP_ENV=dev'));
      expect(readme, contains('APP_ENV=staging'));
      expect(readme, contains('APP_ENV=production'));
    });

    test('no file has unsubstituted {{projectName}} placeholder', () {
      for (final entry in fileMap.entries) {
        expect(
          entry.value,
          isNot(contains('{{projectName}}')),
          reason: '${entry.key} still has {{projectName}}',
        );
      }
    });

    test('no file has unsubstituted {{ControllerName}} placeholder', () {
      for (final entry in fileMap.entries) {
        expect(
          entry.value,
          isNot(contains('{{ControllerName}}')),
          reason: '${entry.key} still has {{ControllerName}}',
        );
      }
    });
  });

  // ── Cross-mode property invariants ────────────────────────────────────────

  group('cross-mode invariants', () {
    test(
      'all modes generate hello_controller (except full, which has all controllers)',
      () async {
        final minimal = await CreateCommandConstants.files('myapp');
        final withAuth = await CreateCommandConstants.files(
          'myapp',
          features: {Feature.auth},
        );
        final withDb = await CreateCommandConstants.files(
          'myapp',
          features: {Feature.db},
        );
        final full = await CreateCommandConstants.files('myapp', full: true);

        expect(minimal.keys, contains('myapp/lib/src/controllers/hello_controller.dart'));
        expect(
          withAuth.keys,
          contains('myapp/lib/src/controllers/hello_controller.dart'),
        );
        expect(withDb.keys, contains('myapp/lib/src/controllers/hello_controller.dart'));
        // full mode does not generate hello_controller (it has auth/user/product/etc.)
        expect(
          full.keys,
          isNot(contains('myapp/lib/src/controllers/hello_controller.dart')),
        );
      },
    );

    test('pubspec.yaml always includes dartapi_core', () async {
      final minimal = await CreateCommandConstants.files('myapp');
      final withDb = await CreateCommandConstants.files('myapp', features: {Feature.db});
      final full = await CreateCommandConstants.files('myapp', full: true);

      expect(minimal['myapp/pubspec.yaml'], contains('dartapi_core'));
      expect(withDb['myapp/pubspec.yaml'], contains('dartapi_core'));
      expect(full['myapp/pubspec.yaml'], contains('dartapi_core'));
    });

    test('env files are generated in every mode', () async {
      final minimal = await CreateCommandConstants.files('myapp');
      final full = await CreateCommandConstants.files('myapp', full: true);

      for (final mode in [minimal, full]) {
        expect(mode.keys, containsAll(['myapp/env/.env.dev', 'myapp/env/.env.example']));
      }
    });

    test('full mode generates bootstrap.dart; partial modes do not', () async {
      final minimal = await CreateCommandConstants.files('myapp');
      final withAuth = await CreateCommandConstants.files(
        'myapp',
        features: {Feature.auth},
      );
      final full = await CreateCommandConstants.files('myapp', full: true);

      expect(full.keys, contains('myapp/lib/src/core/bootstrap.dart'));
      expect(minimal.keys, isNot(contains('myapp/lib/src/core/bootstrap.dart')));
      expect(withAuth.keys, isNot(contains('myapp/lib/src/core/bootstrap.dart')));
    });
  });
}
