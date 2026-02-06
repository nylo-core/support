import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/dart_console/src/textalignment.dart';

void main() {
  group('TextAlignment', () {
    test('has left value', () {
      expect(TextAlignment.left, isNotNull);
    });

    test('has center value', () {
      expect(TextAlignment.center, isNotNull);
    });

    test('has right value', () {
      expect(TextAlignment.right, isNotNull);
    });

    test('has exactly 3 values', () {
      expect(TextAlignment.values.length, equals(3));
    });

    test('values are distinct', () {
      expect(TextAlignment.left, isNot(equals(TextAlignment.center)));
      expect(TextAlignment.left, isNot(equals(TextAlignment.right)));
      expect(TextAlignment.center, isNot(equals(TextAlignment.right)));
    });
  });
}
