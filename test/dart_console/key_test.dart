import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/dart_console/src/key.dart';

void main() {
  group('ControlCharacter', () {
    test('has none value', () {
      expect(ControlCharacter.none, isNotNull);
    });

    test('has control character values', () {
      expect(ControlCharacter.ctrlA, isNotNull);
      expect(ControlCharacter.ctrlB, isNotNull);
      expect(ControlCharacter.ctrlC, isNotNull);
      expect(ControlCharacter.ctrlD, isNotNull);
    });

    test('has navigation keys', () {
      expect(ControlCharacter.arrowLeft, isNotNull);
      expect(ControlCharacter.arrowRight, isNotNull);
      expect(ControlCharacter.arrowUp, isNotNull);
      expect(ControlCharacter.arrowDown, isNotNull);
      expect(ControlCharacter.pageUp, isNotNull);
      expect(ControlCharacter.pageDown, isNotNull);
    });

    test('has special keys', () {
      expect(ControlCharacter.home, isNotNull);
      expect(ControlCharacter.end, isNotNull);
      expect(ControlCharacter.escape, isNotNull);
      expect(ControlCharacter.delete, isNotNull);
      expect(ControlCharacter.backspace, isNotNull);
    });

    test('has function keys', () {
      expect(ControlCharacter.F1, isNotNull);
      expect(ControlCharacter.F2, isNotNull);
      expect(ControlCharacter.F3, isNotNull);
      expect(ControlCharacter.F4, isNotNull);
      expect(ControlCharacter.F5, isNotNull);
      expect(ControlCharacter.F6, isNotNull);
      expect(ControlCharacter.F7, isNotNull);
      expect(ControlCharacter.F8, isNotNull);
      expect(ControlCharacter.F9, isNotNull);
      expect(ControlCharacter.F10, isNotNull);
      expect(ControlCharacter.F11, isNotNull);
      expect(ControlCharacter.F12, isNotNull);
    });

    test('has unknown value', () {
      expect(ControlCharacter.unknown, isNotNull);
    });

    test('has tab and enter', () {
      expect(ControlCharacter.tab, isNotNull);
      expect(ControlCharacter.enter, isNotNull);
    });
  });

  group('KeyStroke', () {
    group('printable constructor', () {
      test('creates printable keystroke', () {
        const key = KeyStroke.printable('a');

        expect(key.isControl, isFalse);
        expect(key.char, equals('a'));
        expect(key.controlChar, equals(ControlCharacter.none));
      });

      test('stores single character', () {
        const key = KeyStroke.printable('Z');

        expect(key.char, equals('Z'));
        expect(key.char.length, equals(1));
      });

      test('toString returns the character', () {
        const key = KeyStroke.printable('x');

        expect(key.toString(), equals('x'));
      });
    });

    group('control constructor', () {
      test('creates control keystroke', () {
        const key = KeyStroke.control(ControlCharacter.enter);

        expect(key.isControl, isTrue);
        expect(key.char, isEmpty);
        expect(key.controlChar, equals(ControlCharacter.enter));
      });

      test('can create with any control character', () {
        const escapeKey = KeyStroke.control(ControlCharacter.escape);
        const arrowKey = KeyStroke.control(ControlCharacter.arrowUp);
        const ctrlKey = KeyStroke.control(ControlCharacter.ctrlC);

        expect(escapeKey.controlChar, equals(ControlCharacter.escape));
        expect(arrowKey.controlChar, equals(ControlCharacter.arrowUp));
        expect(ctrlKey.controlChar, equals(ControlCharacter.ctrlC));
      });

      test('toString returns control character string', () {
        const key = KeyStroke.control(ControlCharacter.enter);

        expect(key.toString(), contains('enter'));
      });
    });

    group('isControl', () {
      test('is false for printable keystrokes', () {
        const key = KeyStroke.printable('a');
        expect(key.isControl, isFalse);
      });

      test('is true for control keystrokes', () {
        const key = KeyStroke.control(ControlCharacter.escape);
        expect(key.isControl, isTrue);
      });
    });
  });
}
