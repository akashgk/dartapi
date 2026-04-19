import 'package:dartapi/templates/template_engine.dart';

class CreateCommandConstants {
  static List<String> directories(String name) => [
    '$name/lib/src/core',
    '$name/lib/src/controllers',
    '$name/lib/src/models',
    '$name/lib/src/dto',
    '$name/bin',
    '$name/test',
    '$name/test/controllers',
  ];

  static Future<Map<String, String>> files(String name) async {
    final vars = {'projectName': name};
    final entries = await Future.wait([
      _load('main.dart.tmpl', vars).then((v) => MapEntry('$name/bin/main.dart', v)),
      _load('token_response.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/models/token_response.dart', v)),
      _load('pubspec.yaml.tmpl', vars).then((v) => MapEntry('$name/pubspec.yaml', v)),
      _load('analysis_options.yaml.tmpl', vars).then((v) => MapEntry('$name/analysis_options.yaml', v)),
      _load('dartapi.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/core/dartapi.dart', v)),
      _load('user_controller_test.dart.tmpl', vars).then((v) => MapEntry('$name/test/controllers/user_controller_test.dart', v)),
      _load('auth_controller_test.dart.tmpl', vars).then((v) => MapEntry('$name/test/controllers/auth_controller_test.dart', v)),
      _load('router.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/core/router.dart', v)),
      _load('core.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/core/core.dart', v)),
      _load('auth_controller.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/controllers/auth_controller.dart', v)),
      _load('user_controller.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/controllers/user_controller.dart', v)),
      _load('product_controller.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/controllers/product_controller.dart', v)),
      _load('user_dto.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/dto/user_dto.dart', v)),
      _load('login_dto.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/dto/login_dto.dart', v)),
      _load('product_dto.dart.tmpl', vars).then((v) => MapEntry('$name/lib/src/dto/product_dto.dart', v)),
    ]);
    return Map.fromEntries(entries);
  }

  static Future<String> _load(String name, Map<String, String> vars) =>
      TemplateEngine.render(name, vars);
}
