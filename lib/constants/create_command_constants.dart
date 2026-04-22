import 'package:dartapi/templates/template_engine.dart';

class CreateCommandConstants {
  static List<String> directories(String name) => [
    '$name/lib/src/core',
    '$name/lib/src/config',
    '$name/lib/src/controllers',
    '$name/lib/src/services',
    '$name/lib/src/repositories',
    '$name/lib/src/models',
    '$name/lib/src/dto',
    '$name/bin',
    '$name/env',
    '$name/migrations',
    '$name/test',
    '$name/test/services',
  ];

  static Future<Map<String, String>> files(String name) async {
    final vars = {'projectName': name};
    final entries = await Future.wait([
      // Entry point
      _load('main.dart.tmpl', vars).then((v) => MapEntry('$name/bin/main.dart', v)),
      // Config
      _load('app_config.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/config/app_config.dart', v)),
      _load('env_loader.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/config/env_loader.dart', v)),
      // Core
      _load('dartapi.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/core/dartapi.dart', v)),
      _load('router.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/core/router.dart', v)),
      _load('core.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/core/core.dart', v)),
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
      _load('pubspec.yaml.tmpl', vars).then((v) => MapEntry('$name/pubspec.yaml', v)),
      _load('analysis_options.yaml.tmpl', vars).then((v) => MapEntry('$name/analysis_options.yaml', v)),
      _load('gitignore.tmpl', vars).then((v) => MapEntry('$name/.gitignore', v)),
      _load('readme.md.tmpl', vars).then((v) => MapEntry('$name/README.md', v)),
    ]);
    return Map.fromEntries(entries);
  }

  static Future<String> _load(String name, Map<String, String> vars) =>
      TemplateEngine.render(name, vars);
}
