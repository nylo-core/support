import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/dart_console/src/ansi.dart';

void main() {
  group('ANSI Constants', () {
    group('device status', () {
      test(
        'should have correct device status report cursor position sequence',
        () {
          expect(ansiDeviceStatusReportCursorPosition, equals('\x1b[6n'));
        },
      );
    });

    group('erase sequences', () {
      test('should have correct erase in display all sequence', () {
        expect(ansiEraseInDisplayAll, equals('\x1b[2J'));
      });

      test('should have correct erase in line all sequence', () {
        expect(ansiEraseInLineAll, equals('\x1b[2K'));
      });

      test('should have correct erase cursor to end sequence', () {
        expect(ansiEraseCursorToEnd, equals('\x1b[K'));
      });
    });

    group('cursor visibility', () {
      test('should have correct hide cursor sequence', () {
        expect(ansiHideCursor, equals('\x1b[?25l'));
      });

      test('should have correct show cursor sequence', () {
        expect(ansiShowCursor, equals('\x1b[?25h'));
      });
    });

    group('cursor movement', () {
      test('should have correct cursor left sequence', () {
        expect(ansiCursorLeft, equals('\x1b[D'));
      });

      test('should have correct cursor right sequence', () {
        expect(ansiCursorRight, equals('\x1b[C'));
      });

      test('should have correct cursor up sequence', () {
        expect(ansiCursorUp, equals('\x1b[A'));
      });

      test('should have correct cursor down sequence', () {
        expect(ansiCursorDown, equals('\x1b[B'));
      });

      test('should have correct reset cursor position sequence', () {
        expect(ansiResetCursorPosition, equals('\x1b[H'));
      });

      test('should have correct move cursor to screen edge sequence', () {
        expect(ansiMoveCursorToScreenEdge, equals('\x1b[999C\x1b[999B'));
      });
    });

    group('reset color', () {
      test('should have correct reset color sequence', () {
        expect(ansiResetColor, equals('\x1b[m'));
      });
    });
  });

  group('ansiCursorPosition', () {
    test('should return correct sequence for position (1, 1)', () {
      expect(ansiCursorPosition(1, 1), equals('\x1b[1;1H'));
    });

    test('should return correct sequence for arbitrary position', () {
      expect(ansiCursorPosition(10, 20), equals('\x1b[10;20H'));
    });

    test('should handle large row and column values', () {
      expect(ansiCursorPosition(999, 999), equals('\x1b[999;999H'));
    });

    test('should handle zero values', () {
      expect(ansiCursorPosition(0, 0), equals('\x1b[0;0H'));
    });
  });

  group('ansiSetColor', () {
    test('should return correct sequence for standard foreground colors', () {
      // Black foreground
      expect(ansiSetColor(30), equals('\x1b[30m'));
      // Red foreground
      expect(ansiSetColor(31), equals('\x1b[31m'));
      // Green foreground
      expect(ansiSetColor(32), equals('\x1b[32m'));
      // White foreground
      expect(ansiSetColor(37), equals('\x1b[37m'));
    });

    test('should return correct sequence for standard background colors', () {
      // Black background
      expect(ansiSetColor(40), equals('\x1b[40m'));
      // Red background
      expect(ansiSetColor(41), equals('\x1b[41m'));
    });

    test('should return correct sequence for bright colors', () {
      // Bright black foreground
      expect(ansiSetColor(90), equals('\x1b[90m'));
      // Bright white foreground
      expect(ansiSetColor(97), equals('\x1b[97m'));
    });
  });

  group('ansiSetExtendedForegroundColor', () {
    test('should return correct sequence for 256-color foreground', () {
      expect(ansiSetExtendedForegroundColor(0), equals('\x1b[38;5;0m'));
      expect(ansiSetExtendedForegroundColor(255), equals('\x1b[38;5;255m'));
      expect(ansiSetExtendedForegroundColor(128), equals('\x1b[38;5;128m'));
    });

    test('should handle standard color indices (0-15)', () {
      for (var i = 0; i <= 15; i++) {
        expect(ansiSetExtendedForegroundColor(i), equals('\x1b[38;5;${i}m'));
      }
    });

    test('should handle grayscale indices (232-255)', () {
      for (var i = 232; i <= 255; i++) {
        expect(ansiSetExtendedForegroundColor(i), equals('\x1b[38;5;${i}m'));
      }
    });
  });

  group('ansiSetExtendedBackgroundColor', () {
    test('should return correct sequence for 256-color background', () {
      expect(ansiSetExtendedBackgroundColor(0), equals('\x1b[48;5;0m'));
      expect(ansiSetExtendedBackgroundColor(255), equals('\x1b[48;5;255m'));
      expect(ansiSetExtendedBackgroundColor(128), equals('\x1b[48;5;128m'));
    });

    test('should handle standard color indices (0-15)', () {
      for (var i = 0; i <= 15; i++) {
        expect(ansiSetExtendedBackgroundColor(i), equals('\x1b[48;5;${i}m'));
      }
    });
  });

  group('ansiSetRgbForegroundColor', () {
    test(
      'should return correct sequence for RGB foreground (0, 0, 0) black',
      () {
        expect(ansiSetRgbForegroundColor(0, 0, 0), equals('\x1b[38;2;0;0;0m'));
      },
    );

    test(
      'should return correct sequence for RGB foreground (255, 255, 255) white',
      () {
        expect(
          ansiSetRgbForegroundColor(255, 255, 255),
          equals('\x1b[38;2;255;255;255m'),
        );
      },
    );

    test(
      'should return correct sequence for RGB foreground (255, 0, 0) red',
      () {
        expect(
          ansiSetRgbForegroundColor(255, 0, 0),
          equals('\x1b[38;2;255;0;0m'),
        );
      },
    );

    test(
      'should return correct sequence for RGB foreground (0, 255, 0) green',
      () {
        expect(
          ansiSetRgbForegroundColor(0, 255, 0),
          equals('\x1b[38;2;0;255;0m'),
        );
      },
    );

    test(
      'should return correct sequence for RGB foreground (0, 0, 255) blue',
      () {
        expect(
          ansiSetRgbForegroundColor(0, 0, 255),
          equals('\x1b[38;2;0;0;255m'),
        );
      },
    );

    test('should return correct sequence for arbitrary RGB values', () {
      expect(
        ansiSetRgbForegroundColor(123, 45, 67),
        equals('\x1b[38;2;123;45;67m'),
      );
    });
  });

  group('ansiSetRgbBackgroundColor', () {
    test(
      'should return correct sequence for RGB background (0, 0, 0) black',
      () {
        expect(ansiSetRgbBackgroundColor(0, 0, 0), equals('\x1b[48;2;0;0;0m'));
      },
    );

    test(
      'should return correct sequence for RGB background (255, 255, 255) white',
      () {
        expect(
          ansiSetRgbBackgroundColor(255, 255, 255),
          equals('\x1b[48;2;255;255;255m'),
        );
      },
    );

    test(
      'should return correct sequence for RGB background (255, 0, 0) red',
      () {
        expect(
          ansiSetRgbBackgroundColor(255, 0, 0),
          equals('\x1b[48;2;255;0;0m'),
        );
      },
    );

    test('should return correct sequence for arbitrary RGB values', () {
      expect(
        ansiSetRgbBackgroundColor(100, 150, 200),
        equals('\x1b[48;2;100;150;200m'),
      );
    });
  });

  group('ansiSetTextStyles', () {
    test('should return empty style sequence when no styles provided', () {
      expect(ansiSetTextStyles(), equals('\x1b[m'));
    });

    test('should return correct sequence for bold only', () {
      expect(ansiSetTextStyles(bold: true), equals('\x1b[1m'));
    });

    test('should return correct sequence for faint only', () {
      expect(ansiSetTextStyles(faint: true), equals('\x1b[2m'));
    });

    test('should return correct sequence for italic only', () {
      expect(ansiSetTextStyles(italic: true), equals('\x1b[3m'));
    });

    test('should return correct sequence for underscore only', () {
      expect(ansiSetTextStyles(underscore: true), equals('\x1b[4m'));
    });

    test('should return correct sequence for blink only', () {
      expect(ansiSetTextStyles(blink: true), equals('\x1b[5m'));
    });

    test('should return correct sequence for inverted only', () {
      expect(ansiSetTextStyles(inverted: true), equals('\x1b[7m'));
    });

    test('should return correct sequence for invisible only', () {
      expect(ansiSetTextStyles(invisible: true), equals('\x1b[8m'));
    });

    test('should return correct sequence for strikethru only', () {
      expect(ansiSetTextStyles(strikethru: true), equals('\x1b[9m'));
    });

    test('should return correct sequence for multiple styles combined', () {
      expect(ansiSetTextStyles(bold: true, italic: true), equals('\x1b[1;3m'));
    });

    test('should return correct sequence for all styles combined', () {
      expect(
        ansiSetTextStyles(
          bold: true,
          faint: true,
          italic: true,
          underscore: true,
          blink: true,
          inverted: true,
          invisible: true,
          strikethru: true,
        ),
        equals('\x1b[1;2;3;4;5;7;8;9m'),
      );
    });

    test('should maintain correct order of style codes', () {
      // Style codes should be in order: bold(1), faint(2), italic(3), underscore(4),
      // blink(5), inverted(7), invisible(8), strikethru(9)
      expect(
        ansiSetTextStyles(strikethru: true, bold: true, underscore: true),
        equals('\x1b[1;4;9m'),
      );
    });
  });
}
