import 'dart:io';

import 'package:dartapi/dartapi.dart';
import 'package:test/test.dart';

void main() {
  late Directory tmpDir;
  late Directory savedCwd;

  setUp(() {
    savedCwd = Directory.current;
    tmpDir = Directory.systemTemp.createTempSync('dartapi_resource_test_');
    Directory.current = tmpDir;
  });

  tearDown(() {
    Directory.current = savedCwd;
    tmpDir.deleteSync(recursive: true);
  });

  group('generateResource', () {
    test('creates controller, dto, and model files', () async {
      await generateResource('Order');
      expect(File('lib/src/controllers/order_controller.dart').existsSync(), isTrue);
      expect(File('lib/src/dto/order_dto.dart').existsSync(), isTrue);
      expect(File('lib/src/models/order.dart').existsSync(), isTrue);
    });

    test('controller defines the correct class name', () async {
      await generateResource('Product');
      final content =
          File('lib/src/controllers/product_controller.dart').readAsStringSync();
      expect(content, contains('class ProductController'));
    });

    test('controller extends BaseController', () async {
      await generateResource('Invoice');
      final content =
          File('lib/src/controllers/invoice_controller.dart').readAsStringSync();
      expect(content, contains('extends BaseController'));
    });

    test('controller has all 5 CRUD routes', () async {
      await generateResource('Widget');
      final content =
          File('lib/src/controllers/widget_controller.dart').readAsStringSync();
      expect(content, contains('ApiMethod.get'));
      expect(content, contains('ApiMethod.post'));
      expect(content, contains('ApiMethod.put'));
      expect(content, contains('ApiMethod.delete'));
    });

    test('controller uses pluralised path', () async {
      await generateResource('Tag');
      final content =
          File('lib/src/controllers/tag_controller.dart').readAsStringSync();
      expect(content, contains("'/tags'"));
    });

    test('model defines the correct class', () async {
      await generateResource('Category');
      final content =
          File('lib/src/models/category.dart').readAsStringSync();
      expect(content, contains('class Category'));
      expect(content, contains('implements Serializable'));
      expect(content, contains('toJson'));
    });

    test('dto defines the correct class', () async {
      await generateResource('Review');
      final content = File('lib/src/dto/review_dto.dart').readAsStringSync();
      expect(content, contains('class ReviewDto'));
      expect(content, contains('fromJson'));
      expect(content, contains('toMap'));
    });

    test('no unsubstituted {{ResourceName}} placeholders remain', () async {
      await generateResource('Item');
      for (final path in [
        'lib/src/controllers/item_controller.dart',
        'lib/src/dto/item_dto.dart',
        'lib/src/models/item.dart',
      ]) {
        final content = File(path).readAsStringSync();
        expect(content, isNot(contains('{{ResourceName}}')),
            reason: '$path still has {{ResourceName}} placeholder');
        expect(content, isNot(contains('{{resourcePath}}')),
            reason: '$path still has {{resourcePath}} placeholder');
      }
    });

    test('lowercase input is capitalised in class names', () async {
      await generateResource('payment');
      final content =
          File('lib/src/controllers/payment_controller.dart').readAsStringSync();
      expect(content, contains('class PaymentController'));
    });

    test('delete route returns null for 204', () async {
      await generateResource('Note');
      final content =
          File('lib/src/controllers/note_controller.dart').readAsStringSync();
      expect(content, contains('ApiMethod.delete'));
      expect(content, contains('return null'));
    });
  });
}
