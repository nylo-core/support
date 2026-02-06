import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/dart_console/src/consolecolor.dart';

void main() {
  group('ConsoleColor', () {
    group('standard colors', () {
      test('black has correct ANSI codes', () {
        expect(
          ConsoleColor.black.ansiSetForegroundColorSequence,
          equals('\x1b[30m'),
        );
        expect(
          ConsoleColor.black.ansiSetBackgroundColorSequence,
          equals('\x1b[40m'),
        );
      });

      test('red has correct ANSI codes', () {
        expect(
          ConsoleColor.red.ansiSetForegroundColorSequence,
          equals('\x1b[31m'),
        );
        expect(
          ConsoleColor.red.ansiSetBackgroundColorSequence,
          equals('\x1b[41m'),
        );
      });

      test('green has correct ANSI codes', () {
        expect(
          ConsoleColor.green.ansiSetForegroundColorSequence,
          equals('\x1b[32m'),
        );
        expect(
          ConsoleColor.green.ansiSetBackgroundColorSequence,
          equals('\x1b[42m'),
        );
      });

      test('yellow has correct ANSI codes', () {
        expect(
          ConsoleColor.yellow.ansiSetForegroundColorSequence,
          equals('\x1b[33m'),
        );
        expect(
          ConsoleColor.yellow.ansiSetBackgroundColorSequence,
          equals('\x1b[43m'),
        );
      });

      test('blue has correct ANSI codes', () {
        expect(
          ConsoleColor.blue.ansiSetForegroundColorSequence,
          equals('\x1b[34m'),
        );
        expect(
          ConsoleColor.blue.ansiSetBackgroundColorSequence,
          equals('\x1b[44m'),
        );
      });

      test('magenta has correct ANSI codes', () {
        expect(
          ConsoleColor.magenta.ansiSetForegroundColorSequence,
          equals('\x1b[35m'),
        );
        expect(
          ConsoleColor.magenta.ansiSetBackgroundColorSequence,
          equals('\x1b[45m'),
        );
      });

      test('cyan has correct ANSI codes', () {
        expect(
          ConsoleColor.cyan.ansiSetForegroundColorSequence,
          equals('\x1b[36m'),
        );
        expect(
          ConsoleColor.cyan.ansiSetBackgroundColorSequence,
          equals('\x1b[46m'),
        );
      });

      test('white has correct ANSI codes', () {
        expect(
          ConsoleColor.white.ansiSetForegroundColorSequence,
          equals('\x1b[37m'),
        );
        expect(
          ConsoleColor.white.ansiSetBackgroundColorSequence,
          equals('\x1b[47m'),
        );
      });
    });

    group('bright colors', () {
      test('brightBlack has correct ANSI codes', () {
        expect(
          ConsoleColor.brightBlack.ansiSetForegroundColorSequence,
          equals('\x1b[90m'),
        );
        expect(
          ConsoleColor.brightBlack.ansiSetBackgroundColorSequence,
          equals('\x1b[100m'),
        );
      });

      test('brightRed has correct ANSI codes', () {
        expect(
          ConsoleColor.brightRed.ansiSetForegroundColorSequence,
          equals('\x1b[91m'),
        );
        expect(
          ConsoleColor.brightRed.ansiSetBackgroundColorSequence,
          equals('\x1b[101m'),
        );
      });

      test('brightGreen has correct ANSI codes', () {
        expect(
          ConsoleColor.brightGreen.ansiSetForegroundColorSequence,
          equals('\x1b[92m'),
        );
        expect(
          ConsoleColor.brightGreen.ansiSetBackgroundColorSequence,
          equals('\x1b[102m'),
        );
      });

      test('brightYellow has correct ANSI codes', () {
        expect(
          ConsoleColor.brightYellow.ansiSetForegroundColorSequence,
          equals('\x1b[93m'),
        );
        expect(
          ConsoleColor.brightYellow.ansiSetBackgroundColorSequence,
          equals('\x1b[103m'),
        );
      });

      test('brightBlue has correct ANSI codes', () {
        expect(
          ConsoleColor.brightBlue.ansiSetForegroundColorSequence,
          equals('\x1b[94m'),
        );
        expect(
          ConsoleColor.brightBlue.ansiSetBackgroundColorSequence,
          equals('\x1b[104m'),
        );
      });

      test('brightMagenta has correct ANSI codes', () {
        expect(
          ConsoleColor.brightMagenta.ansiSetForegroundColorSequence,
          equals('\x1b[95m'),
        );
        expect(
          ConsoleColor.brightMagenta.ansiSetBackgroundColorSequence,
          equals('\x1b[105m'),
        );
      });

      test('brightCyan has correct ANSI codes', () {
        expect(
          ConsoleColor.brightCyan.ansiSetForegroundColorSequence,
          equals('\x1b[96m'),
        );
        expect(
          ConsoleColor.brightCyan.ansiSetBackgroundColorSequence,
          equals('\x1b[106m'),
        );
      });

      test('brightWhite has correct ANSI codes', () {
        expect(
          ConsoleColor.brightWhite.ansiSetForegroundColorSequence,
          equals('\x1b[97m'),
        );
        expect(
          ConsoleColor.brightWhite.ansiSetBackgroundColorSequence,
          equals('\x1b[107m'),
        );
      });
    });

    test('has exactly 16 colors', () {
      expect(ConsoleColor.values.length, equals(16));
    });

    test('all colors have non-empty ANSI sequences', () {
      for (final color in ConsoleColor.values) {
        expect(color.ansiSetForegroundColorSequence, isNotEmpty);
        expect(color.ansiSetBackgroundColorSequence, isNotEmpty);
      }
    });

    test('all colors start with escape character', () {
      for (final color in ConsoleColor.values) {
        expect(color.ansiSetForegroundColorSequence, startsWith('\x1b['));
        expect(color.ansiSetBackgroundColorSequence, startsWith('\x1b['));
      }
    });

    test('all colors end with m', () {
      for (final color in ConsoleColor.values) {
        expect(color.ansiSetForegroundColorSequence, endsWith('m'));
        expect(color.ansiSetBackgroundColorSequence, endsWith('m'));
      }
    });
  });
}
