import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/dart_console/src/ffi/win/termlib_win.dart';
import 'package:win32/win32.dart';

void main() {
  group('TermLibWindows.disabledRawModeMask', () {
    final mask = TermLibWindows.disabledRawModeMask;

    test('is non-zero (regression: a bitwise-AND chain reduced it to 0)', () {
      expect(mask, isNonZero);
    });

    test('enables ENABLE_LINE_INPUT so Enter terminates a readLineSync', () {
      expect(mask & ENABLE_LINE_INPUT, isNonZero);
    });

    test('enables ENABLE_ECHO_INPUT so typed input is visible', () {
      expect(mask & ENABLE_ECHO_INPUT, isNonZero);
    });

    test('enables ENABLE_PROCESSED_INPUT for CR/LF and Ctrl+C handling', () {
      expect(mask & ENABLE_PROCESSED_INPUT, isNonZero);
    });

    test('enables ENABLE_VIRTUAL_TERMINAL_INPUT for ANSI escape support', () {
      expect(mask & ENABLE_VIRTUAL_TERMINAL_INPUT, isNonZero);
    });

    test('enables ENABLE_EXTENDED_FLAGS', () {
      expect(mask & ENABLE_EXTENDED_FLAGS, isNonZero);
    });
  });
}
