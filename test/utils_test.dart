import 'package:dartapi/utils.dart';
import 'package:test/test.dart';

void main() {
  group('StringCasingExtension.capitalize', () {
    test('upcases first character of lowercase string', () {
      expect('hello'.capitalize(), 'Hello');
    });

    test('is a no-op on already-capitalized string', () {
      expect('Hello'.capitalize(), 'Hello');
    });

    test('handles empty string', () {
      expect(''.capitalize(), '');
    });

    test('handles single lowercase character', () {
      expect('a'.capitalize(), 'A');
    });

    test('does not alter characters after the first', () {
      expect('hELLO'.capitalize(), 'HELLO');
    });
  });
}
