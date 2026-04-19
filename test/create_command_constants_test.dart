import 'package:dartapi/constants/create_command_constants.dart';
import 'package:test/test.dart';

void main() {
  group('CreateCommandConstants.directories', () {
    test('returns all expected directories for a given project name', () {
      final dirs = CreateCommandConstants.directories('myapp');
      expect(dirs, containsAll([
        'myapp/lib/src/core',
        'myapp/lib/src/config',
        'myapp/lib/src/controllers',
        'myapp/lib/src/models',
        'myapp/lib/src/dto',
        'myapp/bin',
        'myapp/test',
        'myapp/test/controllers',
      ]));
    });

    test('all paths are prefixed with the project name', () {
      final dirs = CreateCommandConstants.directories('alpha');
      for (final dir in dirs) {
        expect(dir, startsWith('alpha/'));
      }
    });
  });

  group('CreateCommandConstants.files', () {
    late Map<String, String> fileMap;

    setUpAll(() async {
      fileMap = await CreateCommandConstants.files('myapp');
    });

    test('returns all expected file paths', () {
      expect(fileMap.keys, containsAll([
        'myapp/bin/main.dart',
        'myapp/pubspec.yaml',
        'myapp/analysis_options.yaml',
        'myapp/lib/src/core/dartapi.dart',
        'myapp/lib/src/core/router.dart',
        'myapp/lib/src/core/core.dart',
        'myapp/lib/src/config/app_config.dart',
        'myapp/lib/src/controllers/auth_controller.dart',
        'myapp/lib/src/controllers/user_controller.dart',
        'myapp/lib/src/controllers/product_controller.dart',
        'myapp/lib/src/dto/user_dto.dart',
        'myapp/lib/src/dto/login_dto.dart',
        'myapp/lib/src/dto/product_dto.dart',
        'myapp/lib/src/models/token_response.dart',
        'myapp/test/controllers/user_controller_test.dart',
        'myapp/test/controllers/auth_controller_test.dart',
      ]));
    });

    test('pubspec.yaml contains the project name', () {
      expect(fileMap['myapp/pubspec.yaml'], contains('name: myapp'));
    });

    test('pubspec.yaml lists dartapi_core as a dependency', () {
      expect(fileMap['myapp/pubspec.yaml'], contains('dartapi_core'));
    });

    test('pubspec.yaml lists dartapi_auth as a dependency', () {
      expect(fileMap['myapp/pubspec.yaml'], contains('dartapi_auth'));
    });

    test('pubspec.yaml lists dartapi_db as a dependency', () {
      expect(fileMap['myapp/pubspec.yaml'], contains('dartapi_db'));
    });

    test('auth_controller.dart defines AuthController class', () {
      expect(
        fileMap['myapp/lib/src/controllers/auth_controller.dart'],
        contains('class AuthController'),
      );
    });

    test('user_controller.dart defines UserController class', () {
      expect(
        fileMap['myapp/lib/src/controllers/user_controller.dart'],
        contains('class UserController'),
      );
    });

    test('product_controller.dart defines ProductController class', () {
      expect(
        fileMap['myapp/lib/src/controllers/product_controller.dart'],
        contains('class ProductController'),
      );
    });

    test('app_config.dart extends EnvConfig', () {
      expect(
        fileMap['myapp/lib/src/config/app_config.dart'],
        contains('extends EnvConfig'),
      );
    });

    test('dartapi.dart defines DartAPI class', () {
      expect(
        fileMap['myapp/lib/src/core/dartapi.dart'],
        contains('class DartAPI'),
      );
    });

    test('no file still contains {{projectName}} placeholder', () {
      for (final entry in fileMap.entries) {
        expect(
          entry.value,
          isNot(contains('{{projectName}}')),
          reason: '${entry.key} still has an unsubstituted {{projectName}} placeholder',
        );
      }
    });

    test('no file still contains {{ControllerName}} placeholder', () {
      for (final entry in fileMap.entries) {
        expect(
          entry.value,
          isNot(contains('{{ControllerName}}')),
          reason: '${entry.key} still has an unsubstituted {{ControllerName}} placeholder',
        );
      }
    });
  });
}
