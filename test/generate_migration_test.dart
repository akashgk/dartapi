import 'dart:io';

import 'package:dartapi/dartapi.dart';
import 'package:test/test.dart';

void main() {
  late Directory tmpDir;
  late Directory savedCwd;

  setUp(() {
    savedCwd = Directory.current;
    tmpDir = Directory.systemTemp.createTempSync('dartapi_migration_test_');
    Directory.current = tmpDir;
  });

  tearDown(() {
    Directory.current = savedCwd;
    tmpDir.deleteSync(recursive: true);
  });

  group('generateMigration', () {
    test('creates migrations/ directory when absent', () {
      generateMigration('create_users');
      expect(Directory('migrations').existsSync(), isTrue);
    });

    test('first migration is numbered 0001', () {
      generateMigration('create_users');
      final files = Directory('migrations').listSync().whereType<File>().toList();
      expect(files.length, 1);
      expect(files.first.uri.pathSegments.last, startsWith('0001_'));
    });

    test('migration filename contains sanitized name', () {
      generateMigration('Create Users Table!');
      final files = Directory('migrations').listSync().whereType<File>().toList();
      final name = files.first.uri.pathSegments.last;
      expect(name, contains('create_users_table_'));
      expect(name, isNot(contains(' ')));
      expect(name, isNot(contains('!')));
    });

    test('second migration is numbered 0002', () {
      generateMigration('first');
      generateMigration('second');
      final files = Directory('migrations')
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .toList()
        ..sort();
      expect(files[0], startsWith('0001_'));
      expect(files[1], startsWith('0002_'));
    });

    test('migration file contains SQL comment header', () {
      generateMigration('add_index');
      final files = Directory('migrations').listSync().whereType<File>().toList();
      final content = files.first.readAsStringSync();
      expect(content, contains('-- Migration:'));
      expect(content, contains('-- Created by dartapi'));
    });

    test('migration file ends with .sql extension', () {
      generateMigration('drop_table');
      final files = Directory('migrations').listSync().whereType<File>().toList();
      expect(files.first.path, endsWith('.sql'));
    });

    test('existing migrations/ directory is reused without error', () {
      Directory('migrations').createSync();
      expect(() => generateMigration('no_op'), returnsNormally);
    });
  });
}
