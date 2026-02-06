import 'package:flutter_test/flutter_test.dart';
import 'package:nylo_support/dart_console/ny_dart_console.dart';
import 'package:nylo_support/metro/src/metro_console.dart';
import 'package:nylo_support/testing/ny_testing.dart';

void main() {
  NyTest.init();

  nyGroup('MetroConsole', () {
    nyGroup('hyperlink', () {
      nyTest('should create OSC 8 hyperlink', () async {
        final link = MetroConsole.hyperlink('test.dart', 'lib/test.dart');
        expect(link, contains('test.dart'));
        expect(link, contains('\x1B]8;;'));
        expect(link, contains('\x07'));
      });

      nyTest('should contain file:// protocol', () async {
        final link = MetroConsole.hyperlink('test.dart', 'lib/test.dart');
        expect(link, contains('file://'));
      });
    });

    nyGroup('coloredHyperlink', () {
      nyTest('should create colored hyperlink', () async {
        final link = MetroConsole.coloredHyperlink(
          'test.dart',
          'lib/test.dart',
          ConsoleColor.brightGreen,
        );
        expect(link, contains('test.dart'));
        expect(link, contains('\x1B]8;;'));
      });

      nyTest('should include color escape sequence', () async {
        final link = MetroConsole.coloredHyperlink(
          'test.dart',
          'lib/test.dart',
          ConsoleColor.red,
        );
        expect(link, contains(ConsoleColor.red.ansiSetForegroundColorSequence));
      });

      nyTest('should include bold when requested', () async {
        final link = MetroConsole.coloredHyperlink(
          'test.dart',
          'lib/test.dart',
          ConsoleColor.green,
          bold: true,
        );
        expect(link, contains('\x1B[1m'));
      });
    });
  });
}
