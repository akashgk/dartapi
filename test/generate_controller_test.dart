import 'dart:io';

import 'package:dartapi/dartapi.dart';
import 'package:test/test.dart';

void main() {
  late Directory tmpDir;
  late Directory savedCwd;

  setUp(() {
    savedCwd = Directory.current;
    tmpDir = Directory.systemTemp.createTempSync('dartapi_controller_test_');
    Directory.current = tmpDir;
  });

  tearDown(() {
    Directory.current = savedCwd;
    tmpDir.deleteSync(recursive: true);
  });

  group('generateController', () {
    test('creates controller file at expected path', () async {
      await generateController('Product');
      expect(
        File('lib/src/controllers/product_controller.dart').existsSync(),
        isTrue,
      );
    });

    test('generated file defines the correct class name', () async {
      await generateController('Order');
      final content =
          File('lib/src/controllers/order_controller.dart').readAsStringSync();
      expect(content, contains('class OrderController'));
    });

    test('generated controller extends BaseController', () async {
      await generateController('Invoice');
      final content =
          File('lib/src/controllers/invoice_controller.dart').readAsStringSync();
      expect(content, contains('extends BaseController'));
    });

    test('generated file has a routes getter', () async {
      await generateController('Payment');
      final content =
          File('lib/src/controllers/payment_controller.dart').readAsStringSync();
      expect(content, contains('get routes'));
    });

    test('route path uses lowercase controller name', () async {
      await generateController('Widget');
      final content =
          File('lib/src/controllers/widget_controller.dart').readAsStringSync();
      expect(content, contains("'/widget'"));
    });

    test('placeholder {{ControllerName}} is substituted', () async {
      await generateController('Foo');
      final content =
          File('lib/src/controllers/foo_controller.dart').readAsStringSync();
      expect(content, isNot(contains('{{ControllerName}}')));
    });

    test('placeholder {{routePath}} is substituted', () async {
      await generateController('Bar');
      final content =
          File('lib/src/controllers/bar_controller.dart').readAsStringSync();
      expect(content, isNot(contains('{{routePath}}')));
    });

    test('lowercase input is capitalised in class name', () async {
      await generateController('item');
      final content =
          File('lib/src/controllers/item_controller.dart').readAsStringSync();
      expect(content, contains('class ItemController'));
    });
  });
}
