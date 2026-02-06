import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/dart_console/src/string_utils.dart';
import 'package:nylo_support/dart_console/src/textalignment.dart';

void main() {
  group('StringUtils extension', () {
    group('wrapText()', () {
      test('returns empty string for empty input', () {
        expect(''.wrapText(), equals(''));
      });

      test('does not wrap short text', () {
        const text = 'Hello world';
        expect(text.wrapText(), equals(text));
      });

      test('wraps text at default length of 76', () {
        final text = 'a ' * 50; // 100 characters with spaces
        final wrapped = text.wrapText();

        expect(wrapped.contains('\n'), isTrue);
      });

      test('wraps text at custom length', () {
        const text = 'Hello world this is a test';
        final wrapped = text.wrapText(10);

        expect(wrapped.contains('\n'), isTrue);
      });

      test('preserves words', () {
        const text = 'one two three four five';
        final wrapped = text.wrapText(10);

        expect(wrapped, contains('one'));
        expect(wrapped, contains('two'));
        expect(wrapped, contains('three'));
      });

      test('trims trailing whitespace', () {
        const text = 'Hello world';
        final wrapped = text.wrapText();

        expect(wrapped, isNot(endsWith(' ')));
      });
    });

    group('alignText()', () {
      group('left alignment', () {
        test('pads text on the right', () {
          final aligned = 'test'.alignText(
            width: 10,
            alignment: TextAlignment.left,
          );

          expect(aligned.length, equals(10));
          expect(aligned, startsWith('test'));
          expect(aligned, endsWith('      '));
        });

        test('handles text equal to width', () {
          final aligned = 'test'.alignText(
            width: 4,
            alignment: TextAlignment.left,
          );

          expect(aligned, equals('test'));
        });
      });

      group('right alignment', () {
        test('pads text on the left', () {
          final aligned = 'test'.alignText(
            width: 10,
            alignment: TextAlignment.right,
          );

          expect(aligned.length, equals(10));
          expect(aligned, endsWith('test'));
          expect(aligned, startsWith('      '));
        });
      });

      group('center alignment', () {
        test('pads text on both sides', () {
          final aligned = 'test'.alignText(
            width: 10,
            alignment: TextAlignment.center,
          );

          expect(aligned.length, equals(10));
          expect(aligned, contains('test'));
        });

        test('handles odd padding correctly', () {
          final aligned = 'a'.alignText(
            width: 4,
            alignment: TextAlignment.center,
          );

          expect(aligned.length, equals(4));
        });
      });

      test('default alignment is left', () {
        final aligned = 'test'.alignText(width: 10);

        expect(aligned, startsWith('test'));
      });
    });

    group('stripEscapeCharacters()', () {
      test('returns string unchanged without escape sequences', () {
        const text = 'Hello World';
        expect(text.stripEscapeCharacters(), equals(text));
      });

      test('removes simple ANSI color codes', () {
        const text = '\x1b[31mRed\x1b[0m';
        expect(text.stripEscapeCharacters(), equals('Red'));
      });

      test('removes multiple escape sequences', () {
        const text = '\x1b[1m\x1b[32mBold Green\x1b[0m';
        expect(text.stripEscapeCharacters(), equals('Bold Green'));
      });

      test('handles empty string', () {
        expect(''.stripEscapeCharacters(), equals(''));
      });
    });

    group('displayWidth', () {
      test('returns length for plain text', () {
        expect('Hello'.displayWidth, equals(5));
      });

      test('excludes ANSI codes from width', () {
        const text = '\x1b[31mRed\x1b[0m';
        expect(text.displayWidth, equals(3));
      });

      test('returns 0 for empty string', () {
        expect(''.displayWidth, equals(0));
      });

      test('handles text with multiple escape sequences', () {
        const text = '\x1b[1mBold\x1b[0m \x1b[32mGreen\x1b[0m';
        expect(text.displayWidth, equals(10)); // 'Bold Green'
      });
    });

    group('superscript()', () {
      test('converts digits to superscript', () {
        expect('0123456789'.superscript(), equals('⁰¹²³⁴⁵⁶⁷⁸⁹'));
      });

      test('leaves non-digits unchanged', () {
        expect('abc'.superscript(), equals('abc'));
      });

      test('handles mixed content', () {
        expect('x2'.superscript(), equals('x²'));
      });

      test('handles empty string', () {
        expect(''.superscript(), equals(''));
      });
    });

    group('subscript()', () {
      test('converts digits to subscript', () {
        expect('0123456789'.subscript(), equals('₀₁₂₃₄₅₆₇₈₉'));
      });

      test('leaves non-digits unchanged', () {
        expect('abc'.subscript(), equals('abc'));
      });

      test('handles mixed content', () {
        expect('H2O'.subscript(), equals('H₂O'));
      });

      test('handles empty string', () {
        expect(''.subscript(), equals(''));
      });
    });
  });
}
